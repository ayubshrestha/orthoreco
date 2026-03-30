import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { Navigate, Route, Routes, useNavigate, useParams } from 'react-router-dom';

type PatientRecord = {
  id: string;
  patientName: string;
  diagnosis: string;
  lastVisit: string;
  status: 'Stable' | 'Needs Follow-up' | 'Critical';
  notes: string;
};

type DoctorAccount = {
  fullName: string;
  email: string;
  password: string;
};

const initialRecords: PatientRecord[] = [
  {
    id: 'PT-1301',
    patientName: 'Sarah Jennings',
    diagnosis: 'Type II Diabetes',
    lastVisit: '2026-03-23',
    status: 'Needs Follow-up',
    notes: 'Review blood sugar report and adjust insulin dosage.'
  },
  {
    id: 'PT-1302',
    patientName: 'Daniel Matthews',
    diagnosis: 'Hypertension',
    lastVisit: '2026-03-25',
    status: 'Stable',
    notes: 'Continue current medication and monitor BP weekly.'
  },
  {
    id: 'PT-1303',
    patientName: 'Rita Gomez',
    diagnosis: 'Post-op Recovery',
    lastVisit: '2026-03-26',
    status: 'Critical',
    notes: 'Daily wound check and infection marker tracking required.'
  }
];

const defaultAccount: DoctorAccount = {
  fullName: 'Dr. Alex Morgan',
  email: 'doctor@hospital.com',
  password: 'doctor123'
};

const STORAGE_DOCTOR_ACCOUNTS_KEY = 'caretrack_doctor_accounts';
const STORAGE_SESSION_KEY = 'caretrack_doctor_session';

type DoctorSession = {
  email: string;
  fullName: string;
};

function loadDoctorAccounts(): DoctorAccount[] {
  if (typeof window === 'undefined') return [defaultAccount];

  const raw = window.localStorage.getItem(STORAGE_DOCTOR_ACCOUNTS_KEY);
  if (!raw) return [defaultAccount];

  try {
    const parsed: unknown = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [defaultAccount];

    const accounts = parsed.filter((x): x is DoctorAccount => {
      if (typeof x !== 'object' || x === null) return false;
      const obj = x as Partial<DoctorAccount>;
      return typeof obj.fullName === 'string' && typeof obj.email === 'string' && typeof obj.password === 'string';
    });

    return accounts.length ? accounts : [defaultAccount];
  } catch {
    return [defaultAccount];
  }
}

function saveDoctorAccounts(accounts: DoctorAccount[]) {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(STORAGE_DOCTOR_ACCOUNTS_KEY, JSON.stringify(accounts));
}

function loadSession(): DoctorSession | null {
  if (typeof window === 'undefined') return null;

  const raw = window.localStorage.getItem(STORAGE_SESSION_KEY);
  if (!raw) return null;

  try {
    const parsed: unknown = JSON.parse(raw);
    if (typeof parsed !== 'object' || parsed === null) return null;
    const obj = parsed as Partial<DoctorSession>;
    if (typeof obj.email !== 'string' || typeof obj.fullName !== 'string') return null;
    return { email: obj.email, fullName: obj.fullName };
  } catch {
    return null;
  }
}

function saveSession(doctor: DoctorAccount) {
  if (typeof window === 'undefined') return;
  const session: DoctorSession = { email: doctor.email, fullName: doctor.fullName };
  window.localStorage.setItem(STORAGE_SESSION_KEY, JSON.stringify(session));
}

function clearSession() {
  if (typeof window === 'undefined') return;
  window.localStorage.removeItem(STORAGE_SESSION_KEY);
}

function App() {
  const [accounts, setAccounts] = useState<DoctorAccount[]>(() => loadDoctorAccounts());
  const [loggedInDoctor, setLoggedInDoctor] = useState<DoctorAccount | null>(() => {
    const session = loadSession();
    if (!session) return null;
    const loadedAccounts = loadDoctorAccounts();
    return loadedAccounts.find((d) => d.email === session.email) ?? null;
  });
  const [records] = useState<PatientRecord[]>(initialRecords);

  return (
    <Routes>
      <Route
        path="/"
        element={loggedInDoctor ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />}
      />
      <Route
        path="/login"
        element={
          <LoginPage
            accounts={accounts}
            onLogin={(doctor) => {
              saveSession(doctor);
              setLoggedInDoctor(doctor);
            }}
            isLoggedIn={Boolean(loggedInDoctor)}
          />
        }
      />
      <Route
        path="/register"
        element={
          <RegisterPage
            accounts={accounts}
            onRegister={(doctor) => {
              setAccounts((prev) => {
                const next = [...prev, doctor];
                saveDoctorAccounts(next);
                return next;
              });
            }}
          />
        }
      />
      <Route
        path="/dashboard"
        element={
          loggedInDoctor ? (
            <DashboardPage
              doctor={loggedInDoctor}
              records={records}
              onLogout={() => {
                clearSession();
                setLoggedInDoctor(null);
              }}
            />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      />
      <Route
        path="/patients/:patientId"
        element={
          loggedInDoctor ? (
            <PatientDetailsPage
              doctor={loggedInDoctor}
              records={records}
              onLogout={() => {
                clearSession();
                setLoggedInDoctor(null);
              }}
            />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function LoginPage({
  accounts,
  onLogin,
  isLoggedIn
}: {
  accounts: DoctorAccount[];
  onLogin: (doctor: DoctorAccount) => void;
  isLoggedIn: boolean;
}) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [error, setError] = useState('');

  const submitLogin = (event: FormEvent) => {
    event.preventDefault();
    const doctor = accounts.find(
      (d) => d.email.toLowerCase() === formData.email.toLowerCase() && d.password === formData.password
    );
    if (doctor) {
      onLogin(doctor);
      navigate('/dashboard');
      return;
    }
    setError('Invalid email or password.');
  };

  if (isLoggedIn) return <Navigate to="/dashboard" replace />;

  return (
    <main className="auth-layout">
      <section className="auth-panel">
        <h1>Doctor Portal Login</h1>
        <p>Access your patient records and complete daily checks.</p>
        <form onSubmit={submitLogin} className="auth-form">
          <label>
            Email
            <input
              type="email"
              required
              value={formData.email}
              onChange={(e) => setFormData((prev) => ({ ...prev, email: e.target.value }))}
              placeholder="doctor@hospital.com"
            />
          </label>
          <label>
            Password
            <input
              type="password"
              required
              value={formData.password}
              onChange={(e) => setFormData((prev) => ({ ...prev, password: e.target.value }))}
              placeholder="Enter your password"
            />
          </label>
          {error && <p className="error">{error}</p>}
          <button type="submit">Log In</button>
        </form>
        <small>
          New doctor account? <a href="/register">Register here</a>
        </small>
      </section>
    </main>
  );
}

function RegisterPage({
  accounts,
  onRegister
}: {
  accounts: DoctorAccount[];
  onRegister: (doctor: DoctorAccount) => void;
}) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<DoctorAccount>({
    fullName: '',
    email: '',
    password: ''
  });
  const [error, setError] = useState('');

  const submitRegistration = (event: FormEvent) => {
    event.preventDefault();
    const email = formData.email.trim().toLowerCase();
    const exists = accounts.some((a) => a.email.toLowerCase() === email);
    if (exists) {
      setError('An account with this email already exists.');
      return;
    }
    onRegister({ ...formData, email });
    navigate('/login');
  };

  return (
    <main className="auth-layout">
      <section className="auth-panel">
        <h1>Create Doctor Account</h1>
        <p>Register your account before accessing the dashboard.</p>
        <form onSubmit={submitRegistration} className="auth-form">
          <label>
            Full Name
            <input
              type="text"
              required
              value={formData.fullName}
              onChange={(e) => setFormData((prev) => ({ ...prev, fullName: e.target.value }))}
              placeholder="Dr. Jane Smith"
            />
          </label>
          <label>
            Email
            <input
              type="email"
              required
              value={formData.email}
              onChange={(e) => setFormData((prev) => ({ ...prev, email: e.target.value }))}
              placeholder="jane.smith@hospital.com"
            />
          </label>
          <label>
            Password
            <input
              type="password"
              required
              minLength={8}
              value={formData.password}
              onChange={(e) => setFormData((prev) => ({ ...prev, password: e.target.value }))}
              placeholder="Minimum 8 characters"
            />
          </label>
          {error && <p className="error">{error}</p>}
          <button type="submit">Register</button>
        </form>
      </section>
    </main>
  );
}

function DashboardPage({
  doctor,
  records,
  onLogout
}: {
  doctor: DoctorAccount;
  records: PatientRecord[];
  onLogout: () => void;
}) {
  const navigate = useNavigate();
  const [searchValue, setSearchValue] = useState('');
  const [activeMenu, setActiveMenu] = useState<'overview' | 'records' | 'alerts'>('records');

  const filteredRecords = useMemo(() => {
    if (!searchValue) return records;
    const query = searchValue.toLowerCase();
    return records.filter(
      (record) => record.patientName.toLowerCase().includes(query) || record.id.toLowerCase().includes(query)
    );
  }, [records, searchValue]);

  const handleLogout = () => {
    onLogout();
    navigate('/login');
  };

  return (
    <main className="dashboard-layout">
      <aside className="sidebar">
        <h2>CareTrack</h2>
        <nav>
          <button className={activeMenu === 'overview' ? 'active' : ''} onClick={() => setActiveMenu('overview')}>
            Overview
          </button>
          <button className={activeMenu === 'records' ? 'active' : ''} onClick={() => setActiveMenu('records')}>
            Patient Records
          </button>
          <button className={activeMenu === 'alerts' ? 'active' : ''} onClick={() => setActiveMenu('alerts')}>
            Alerts
          </button>
        </nav>
        <button className="logout" onClick={handleLogout}>
          Logout
        </button>
      </aside>
      <section className="content-area">
        <header className="dashboard-header">
          <div>
            <h1>Welcome, {doctor.fullName}</h1>
            <p>Daily patient record review for your treated cases.</p>
          </div>
          <input
            type="search"
            value={searchValue}
            placeholder="Search by patient name or ID"
            onChange={(e) => setSearchValue(e.target.value)}
          />
        </header>

        <div className="stats">
          <article>
            <h3>Total Patients</h3>
            <p>{records.length}</p>
          </article>
          <article>
            <h3>Needs Follow-up</h3>
            <p>{records.filter((record) => record.status === 'Needs Follow-up').length}</p>
          </article>
          <article>
            <h3>Critical Alerts</h3>
            <p>{records.filter((record) => record.status === 'Critical').length}</p>
          </article>
        </div>

        <section className="records-grid">
          {filteredRecords.map((record) => (
            <article
              key={record.id}
              className="record-card clickable"
              role="button"
              tabIndex={0}
              onClick={() => navigate(`/patients/${record.id}`)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' || e.key === ' ') navigate(`/patients/${record.id}`);
              }}
            >
              <div className="record-header">
                <h3>{record.patientName}</h3>
                <span className={`status ${record.status.toLowerCase().replace(' ', '-')}`}>{record.status}</span>
              </div>
              <p>
                <strong>ID:</strong> {record.id}
              </p>
              <p>
                <strong>Diagnosis:</strong> {record.diagnosis}
              </p>
              <p>
                <strong>Last Visit:</strong> {record.lastVisit}
              </p>
              <p className="notes">{record.notes}</p>
            </article>
          ))}
        </section>
      </section>
    </main>
  );
}

function PatientDetailsPage({
  doctor,
  records,
  onLogout
}: {
  doctor: DoctorAccount;
  records: PatientRecord[];
  onLogout: () => void;
}) {
  const navigate = useNavigate();
  const { patientId } = useParams();

  const patient = records.find((r) => r.id === patientId);

  const handleLogout = () => {
    onLogout();
    navigate('/login');
  };

  if (!patientId || !patient) {
    return (
      <main className="dashboard-layout">
        <aside className="sidebar">
          <h2>CareTrack</h2>
          <nav>
            <button className="active" onClick={() => navigate('/dashboard')}>
              Patient Records
            </button>
          </nav>
          <button className="logout" onClick={handleLogout}>
            Logout
          </button>
        </aside>
        <section className="content-area">
          <div className="page-top">
            <button className="secondary" onClick={() => navigate('/dashboard')}>
              ← Back to Dashboard
            </button>
          </div>
          <section className="details-card">
            <h1>Patient not found</h1>
            <p>We couldn’t find a patient record for ID: {patientId ?? '(missing)'}</p>
          </section>
        </section>
      </main>
    );
  }

  return (
    <main className="dashboard-layout">
      <aside className="sidebar">
        <h2>CareTrack</h2>
        <nav>
          <button className="active" onClick={() => navigate('/dashboard')}>
            Patient Records
          </button>
        </nav>
        <button className="logout" onClick={handleLogout}>
          Logout
        </button>
      </aside>
      <section className="content-area">
        <div className="page-top">
          <button className="secondary" onClick={() => navigate('/dashboard')}>
            ← Back to Dashboard
          </button>
          <div className="doctor-chip">Signed in as {doctor.fullName}</div>
        </div>

        <section className="details-card">
          <div className="details-header">
            <div>
              <h1>{patient.patientName}</h1>
              <p className="muted">
                <strong>Patient ID:</strong> {patient.id}
              </p>
            </div>
            <span className={`status ${patient.status.toLowerCase().replace(' ', '-')}`}>{patient.status}</span>
          </div>

          <div className="details-grid">
            <div className="details-item">
              <h3>Diagnosis</h3>
              <p>{patient.diagnosis}</p>
            </div>
            <div className="details-item">
              <h3>Last Visit</h3>
              <p>{patient.lastVisit}</p>
            </div>
            <div className="details-item full">
              <h3>Daily Check Notes</h3>
              <p>{patient.notes}</p>
            </div>
          </div>
        </section>
      </section>
    </main>
  );
}

export default App;
