// Security-rules tests for ../firestore.rules.
// Run with `npm test` (starts the Firestore emulator; needs Java 11+).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  arrayRemove,
  arrayUnion,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const DELETED = 'Deleted user';
let env;

const users = {
  admin: { uid: 'admin', role: 'admin', name: 'Ada Admin' },
  admin2: { uid: 'admin2', role: 'admin', name: 'Second Admin' },
  student: { uid: 'student', role: 'student', name: 'Sam Student' },
  other: { uid: 'other', role: 'student', name: 'Olive Other' },
  staff: {
    uid: 'staff',
    role: 'department_staff',
    name: 'Stan Staff',
    department: 'IT Department',
  },
  plumber: {
    uid: 'plumber',
    role: 'department_staff',
    name: 'Pat Plumber',
    department: 'Plumbing Department',
  },
  coord: { uid: 'coord', role: 'venue_coordinator', name: 'Cora Coord' },
  coord2: { uid: 'coord2', role: 'venue_coordinator', name: 'Cole Coord' },
  inactive: { uid: 'inactive', role: 'student', name: 'Ina', isActive: false },
};

const db = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

function profile(u) {
  return {
    uid: u.uid,
    email: `${u.uid}@campus.edu`,
    name: u.name,
    role: u.role,
    department: u.department ?? null,
    isActive: u.isActive ?? true,
    createdAt: '2026-01-01T00:00:00.000',
  };
}

function booking(overrides = {}) {
  return {
    venueId: 'hall',
    venueName: 'Main Hall',
    studentId: 'student',
    studentName: 'Sam Student',
    coordinatorId: 'coord',
    purpose: 'Club meeting',
    startDate: '2099-05-01T00:00:00.000',
    endDate: '2099-05-01T00:00:00.000',
    isFullDay: true,
    startTime: null,
    endTime: null,
    status: 'pending',
    rejectionReason: null,
    createdAt: '2026-01-01T00:00:00.000',
    updatedAt: '2026-01-01T00:00:00.000',
    ...overrides,
  };
}

const complaint = {
  studentId: 'student',
  studentName: 'Sam Student',
  title: 'Projector broken',
  description: null,
  category: 'it',
  assignedDepartment: 'IT Department',
  location: 'Room 204',
  imageUrls: [],
  status: 'pending_review',
  createdAt: '2026-01-01T00:00:00.000',
  updatedAt: '2026-01-01T00:00:00.000',
};

function notification(recipientId) {
  return {
    recipientId,
    type: 'general',
    title: 'Hello',
    body: 'World',
    actionRoute: null,
    isRead: false,
    createdAt: '2026-01-01T00:00:00.000',
  };
}

function tombstone(uid, deletedBy) {
  return { uid, deletedBy, deletedAt: serverTimestamp() };
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-campushub',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    for (const u of Object.values(users)) {
      await setDoc(doc(fs, 'users', u.uid), profile(u));
    }
    await setDoc(doc(fs, 'venues', 'hall'), {
      name: 'Main Hall',
      coordinatorId: 'coord2',
      isActive: true,
    });
    await setDoc(doc(fs, 'bookings', 'b1'), booking());
    await setDoc(doc(fs, 'complaints', 'c1'), complaint);
    await setDoc(doc(fs, 'notifications', 'n1'), notification('student'));
    await setDoc(doc(fs, 'suggestions', 's1'), {
      authorId: 'other',
      authorName: 'Olive Other',
      title: 'More benches',
      description: 'Near the library',
      upvotedBy: ['student'],
      createdAt: new Date(),
    });
    await setDoc(doc(fs, 'suggestions', 's2'), {
      authorId: 'student',
      authorName: 'Sam Student',
      title: 'Longer library hours',
      description: 'Until midnight',
      upvotedBy: [],
      createdAt: new Date(),
    });
  });
});

// ---------------------------------------------------------------- deletion

describe('account deletion', () => {
  test('a user can delete their own profile together with a tombstone', async () => {
    const fs = db('student');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'deleted_accounts', 'student'), tombstone('student', 'student'));
    batch.delete(doc(fs, 'users', 'student'));
    await assertSucceeds(batch.commit());
  });

  test('a profile cannot be deleted without a tombstone', async () => {
    await assertFails(deleteDoc(doc(db('student'), 'users', 'student')));
  });

  test("a user cannot delete someone else's account", async () => {
    const fs = db('student');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'deleted_accounts', 'other'), tombstone('other', 'student'));
    batch.delete(doc(fs, 'users', 'other'));
    await assertFails(batch.commit());
  });

  test("a user cannot write someone else's tombstone", async () => {
    await assertFails(
      setDoc(doc(db('student'), 'deleted_accounts', 'other'), tombstone('other', 'student')),
    );
  });

  test('staff and coordinators cannot delete other accounts', async () => {
    for (const actor of ['staff', 'coord']) {
      const fs = db(actor);
      const batch = writeBatch(fs);
      batch.set(doc(fs, 'deleted_accounts', 'other'), tombstone('other', actor));
      batch.delete(doc(fs, 'users', 'other'));
      await assertFails(batch.commit());
    }
  });

  test("an admin can delete any user's account", async () => {
    const fs = db('admin');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'deleted_accounts', 'other'), tombstone('other', 'admin'));
    batch.delete(doc(fs, 'users', 'other'));
    await assertSucceeds(batch.commit());
  });

  test('a deactivated admin cannot delete accounts', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'users', 'admin'), { isActive: false }),
    );
    const fs = db('admin');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'deleted_accounts', 'other'), tombstone('other', 'admin'));
    batch.delete(doc(fs, 'users', 'other'));
    await assertFails(batch.commit());
  });

  test('tombstones must name the real deleter and carry no extra data', async () => {
    const fs = db('admin');
    await assertFails(
      setDoc(doc(fs, 'deleted_accounts', 'other'), tombstone('other', 'someone-else')),
    );
    await assertFails(
      setDoc(doc(fs, 'deleted_accounts', 'other'), {
        ...tombstone('other', 'admin'),
        email: 'other@campus.edu',
      }),
    );
  });

  test('tombstones cannot be removed', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'deleted_accounts', 'gone'), {
        uid: 'gone',
        deletedBy: 'admin',
        deletedAt: new Date(),
      }),
    );
    await assertFails(deleteDoc(doc(db('admin'), 'deleted_accounts', 'gone')));
    await assertFails(deleteDoc(doc(db('gone'), 'deleted_accounts', 'gone')));
  });

  test('a deleted user can read only their own tombstone, and nothing else', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'deleted_accounts', 'gone'), {
        uid: 'gone',
        deletedBy: 'admin',
        deletedAt: new Date(),
      });
      await setDoc(doc(fs, 'deleted_accounts', 'gone2'), {
        uid: 'gone2',
        deletedBy: 'admin',
        deletedAt: new Date(),
      });
    });
    const fs = db('gone');
    await assertSucceeds(getDoc(doc(fs, 'deleted_accounts', 'gone')));
    await assertFails(getDoc(doc(fs, 'deleted_accounts', 'gone2')));
    await assertFails(getDocs(collection(fs, 'venues')));
    await assertFails(getDocs(collection(fs, 'bookings')));
  });

  test('owner can anonymise their complaint, but not rewrite it', async () => {
    const fs = db('student');
    await assertSucceeds(updateDoc(doc(fs, 'complaints', 'c1'), { studentName: DELETED }));
    await assertFails(updateDoc(doc(fs, 'complaints', 'c1'), { studentName: 'Someone' }));
    await assertFails(updateDoc(doc(fs, 'complaints', 'c1'), { status: 'resolved' }));
    await assertFails(updateDoc(doc(db('other'), 'complaints', 'c1'), { studentName: DELETED }));
  });

  test('owner can cancel and anonymise their booking', async () => {
    await assertSucceeds(
      updateDoc(doc(db('student'), 'bookings', 'b1'), {
        studentName: DELETED,
        status: 'cancelled',
        updatedAt: '2026-02-01T00:00:00.000',
      }),
    );
  });

  test('owner can delete own notifications; others cannot', async () => {
    await assertFails(deleteDoc(doc(db('other'), 'notifications', 'n1')));
    await assertSucceeds(deleteDoc(doc(db('student'), 'notifications', 'n1')));
  });

  test("admin can delete another user's notifications", async () => {
    await assertSucceeds(deleteDoc(doc(db('admin'), 'notifications', 'n1')));
  });

  test("admin can clean up a large batch of another user's notifications one by one", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      for (let i = 0; i < 40; i++) {
        await setDoc(doc(fs, 'notifications', `bulk${i}`), notification('other'));
      }
    });
    const fs = db('admin');
    const snap = await assertSucceeds(
      getDocs(query(collection(fs, 'notifications'), where('recipientId', '==', 'other'))),
    );
    await assertSucceeds(Promise.all(snap.docs.map((d) => deleteDoc(d.ref))));
  });

  test("authors can delete their suggestions; others can't", async () => {
    await assertFails(deleteDoc(doc(db('other'), 'suggestions', 's2')));
    await assertSucceeds(deleteDoc(doc(db('student'), 'suggestions', 's2')));
    await assertSucceeds(deleteDoc(doc(db('admin'), 'suggestions', 's1')));
  });

  test("admin can remove a deleted user's vote", async () => {
    await assertSucceeds(
      updateDoc(doc(db('admin'), 'suggestions', 's1'), { upvotedBy: arrayRemove('student') }),
    );
  });

  test("a departing coordinator hands pending requests to the venue's coordinator only", async () => {
    const fs = db('coord');
    await assertFails(updateDoc(doc(fs, 'bookings', 'b1'), { coordinatorId: 'other' }));
    await assertSucceeds(updateDoc(doc(fs, 'bookings', 'b1'), { coordinatorId: 'coord2' }));
  });

  test('the remaining admin can list admins (last-admin check)', async () => {
    await assertSucceeds(
      getDocs(query(collection(db('admin'), 'users'), where('role', '==', 'admin'))),
    );
  });
});

// ---------------------------------------------- existing flows (regression)

describe('users', () => {
  test('self-registration creates an active student profile only', async () => {
    const fs = db('newbie');
    await assertFails(
      setDoc(doc(fs, 'users', 'newbie'), { ...profile({ uid: 'newbie', name: 'N', role: 'admin' }) }),
    );
    await assertFails(
      setDoc(doc(fs, 'users', 'someone'), profile({ uid: 'someone', name: 'N', role: 'student' })),
    );
    await assertSucceeds(
      setDoc(doc(fs, 'users', 'newbie'), profile({ uid: 'newbie', name: 'N', role: 'student' })),
    );
  });

  test('users read their own profile only; admins read everyone', async () => {
    await assertSucceeds(getDoc(doc(db('student'), 'users', 'student')));
    await assertFails(getDoc(doc(db('student'), 'users', 'other')));
    await assertFails(getDocs(collection(db('student'), 'users')));
    await assertSucceeds(
      getDocs(query(collection(db('admin'), 'users'), orderBy('createdAt', 'desc'))),
    );
    await assertFails(getDoc(doc(anon(), 'users', 'student')));
  });

  test('only admins create managed accounts and change roles / activation', async () => {
    const managed = profile({ uid: 'newstaff', name: 'N', role: 'department_staff', department: 'IT Department' });
    await assertFails(setDoc(doc(db('student'), 'users', 'newstaff'), managed));
    await assertSucceeds(setDoc(doc(db('admin'), 'users', 'newstaff'), managed));
    await assertFails(updateDoc(doc(db('student'), 'users', 'student'), { role: 'admin' }));
    await assertSucceeds(updateDoc(doc(db('admin'), 'users', 'student'), { role: 'venue_coordinator' }));
    await assertSucceeds(updateDoc(doc(db('admin'), 'users', 'other'), { isActive: false }));
  });
});

describe('complaints', () => {
  test('students submit and list their own complaints', async () => {
    const fs = db('student');
    await assertSucceeds(setDoc(doc(fs, 'complaints', 'c2'), complaint));
    await assertFails(setDoc(doc(fs, 'complaints', 'c3'), { ...complaint, studentId: 'other' }));
    await assertSucceeds(
      getDocs(
        query(collection(fs, 'complaints'), where('studentId', '==', 'student'), orderBy('createdAt', 'desc')),
      ),
    );
    await assertSucceeds(getDoc(doc(fs, 'complaints', 'c1')));
    await assertFails(getDoc(doc(db('other'), 'complaints', 'c1')));
  });

  test('department staff see and update only their department', async () => {
    const q = (fs, dept) =>
      query(collection(fs, 'complaints'), where('assignedDepartment', '==', dept), orderBy('createdAt', 'desc'));
    await assertSucceeds(getDocs(q(db('staff'), 'IT Department')));
    await assertFails(getDocs(q(db('plumber'), 'IT Department')));
    await assertSucceeds(
      updateDoc(doc(db('staff'), 'complaints', 'c1'), { status: 'in_progress', updatedAt: 'x' }),
    );
    await assertFails(updateDoc(doc(db('plumber'), 'complaints', 'c1'), { status: 'resolved' }));
    await assertFails(updateDoc(doc(db('student'), 'complaints', 'c1'), { status: 'resolved' }));
  });

  test('admins read all complaints for reports', async () => {
    await assertSucceeds(getDocs(collection(db('admin'), 'complaints')));
  });
});

describe('bookings', () => {
  test('members create and read bookings (availability check)', async () => {
    const fs = db('other');
    await assertSucceeds(
      setDoc(doc(fs, 'bookings', 'b2'), booking({ studentId: 'other', studentName: 'Olive Other' })),
    );
    await assertFails(setDoc(doc(fs, 'bookings', 'b3'), booking({ status: 'approved', studentId: 'other' })));
    await assertSucceeds(
      getDocs(
        query(collection(fs, 'bookings'), where('venueId', '==', 'hall'), where('status', 'in', ['pending', 'approved'])),
      ),
    );
    await assertSucceeds(
      getDocs(query(collection(fs, 'bookings'), where('studentId', '==', 'other'), orderBy('startDate', 'desc'))),
    );
    await assertFails(getDocs(collection(anon(), 'bookings')));
  });

  test('owners edit and cancel but cannot self-approve', async () => {
    const fs = db('student');
    await assertSucceeds(updateDoc(doc(fs, 'bookings', 'b1'), { purpose: 'Workshop', updatedAt: 'x' }));
    await assertFails(updateDoc(doc(fs, 'bookings', 'b1'), { status: 'approved' }));
    await assertSucceeds(updateDoc(doc(fs, 'bookings', 'b1'), { status: 'cancelled', updatedAt: 'x' }));
    await assertFails(updateDoc(doc(db('other'), 'bookings', 'b1'), { status: 'cancelled' }));
  });

  test('editing an approved booking can send it back to pending', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'bookings', 'b1'), { status: 'approved' }),
    );
    await assertSucceeds(
      updateDoc(doc(db('student'), 'bookings', 'b1'), {
        startDate: '2099-06-01T00:00:00.000',
        endDate: '2099-06-01T00:00:00.000',
        status: 'pending',
        updatedAt: 'x',
      }),
    );
  });

  test('only the assigned coordinator approves or rejects', async () => {
    await assertFails(updateDoc(doc(db('coord2'), 'bookings', 'b1'), { status: 'approved' }));
    await assertSucceeds(
      updateDoc(doc(db('coord'), 'bookings', 'b1'), { status: 'rejected', rejectionReason: 'Busy', updatedAt: 'x' }),
    );
    await assertSucceeds(
      getDocs(query(collection(db('coord'), 'bookings'), where('coordinatorId', '==', 'coord'), orderBy('createdAt', 'desc'))),
    );
  });

  test('admins reassign pending requests when a venue changes coordinator', async () => {
    await assertSucceeds(updateDoc(doc(db('admin'), 'bookings', 'b1'), { coordinatorId: 'coord2' }));
  });
});

describe('venues', () => {
  test('members read; only admins write', async () => {
    await assertSucceeds(getDocs(collection(db('student'), 'venues')));
    await assertFails(updateDoc(doc(db('coord'), 'venues', 'hall'), { name: 'X' }));
    await assertSucceeds(updateDoc(doc(db('admin'), 'venues', 'hall'), { name: 'Grand Hall' }));
    await assertSucceeds(setDoc(doc(db('admin'), 'venues', 'lab'), { name: 'Lab', coordinatorId: 'coord' }));
  });

  test('deactivated users are locked out', async () => {
    await assertFails(getDocs(collection(db('inactive'), 'venues')));
  });
});

describe('suggestions', () => {
  test('members post as themselves', async () => {
    const fs = db('student');
    const data = { authorName: 'Sam', title: 'T', description: 'D', upvotedBy: [], createdAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(fs, 'suggestions', 's3'), { ...data, authorId: 'student' }));
    await assertFails(setDoc(doc(fs, 'suggestions', 's4'), { ...data, authorId: 'other' }));
  });

  test('members toggle only their own vote', async () => {
    const fs = db('staff');
    await assertSucceeds(updateDoc(doc(fs, 'suggestions', 's1'), { upvotedBy: arrayUnion('staff') }));
    await assertSucceeds(updateDoc(doc(fs, 'suggestions', 's1'), { upvotedBy: arrayRemove('staff') }));
    await assertFails(updateDoc(doc(fs, 'suggestions', 's1'), { upvotedBy: arrayRemove('student') }));
    await assertFails(updateDoc(doc(fs, 'suggestions', 's1'), { title: 'Hijacked' }));
  });
});

describe('notifications', () => {
  test('members notify others and read / mark only their own', async () => {
    await assertSucceeds(setDoc(doc(db('student'), 'notifications', 'n2'), notification('coord')));
    await assertSucceeds(
      getDocs(
        query(collection(db('student'), 'notifications'), where('recipientId', '==', 'student'), orderBy('createdAt', 'desc')),
      ),
    );
    await assertFails(
      getDocs(query(collection(db('other'), 'notifications'), where('recipientId', '==', 'student'))),
    );
    await assertSucceeds(updateDoc(doc(db('student'), 'notifications', 'n1'), { isRead: true }));
    await assertFails(updateDoc(doc(db('student'), 'notifications', 'n1'), { body: 'Edited' }));
  });
});
