import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { Navigate, Route, Routes, useNavigate } from 'react-router-dom';

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

function App() {
  const [account, setAccount] = useState<DoctorAccount>(defaultAccount);
  const [loggedInDoctor, setLoggedInDoctor] = useState<DoctorAccount | null>(null);

  return (
    <Routes>
      <Route
        path="/"
        element={loggedInDoctor ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />}
      />
      <Route
        path="/login"
        element={<LoginPage account={account} onLogin={setLoggedInDoctor} isLoggedIn={Boolean(loggedInDoctor)} />}
      />
      <Route path="/register" element={<RegisterPage onRegister={setAccount} />} />
      <Route
        path="/dashboard"
        element={
          loggedInDoctor ? (
            <DashboardPage doctor={loggedInDoctor} records={initialRecords} onLogout={() => setLoggedInDoctor(null)} />
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
  account,
  onLogin,
  isLoggedIn
}: {
  account: DoctorAccount;
  onLogin: (doctor: DoctorAccount) => void;
  isLoggedIn: boolean;
}) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [error, setError] = useState('');

  const submitLogin = (event: FormEvent) => {
    event.preventDefault();
    if (formData.email === account.email && formData.password === account.password) {
      onLogin(account);
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

function RegisterPage({ onRegister }: { onRegister: (doctor: DoctorAccount) => void }) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<DoctorAccount>({
    fullName: '',
    email: '',
    password: ''
  });

  const submitRegistration = (event: FormEvent) => {
    event.preventDefault();
    onRegister(formData);
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
            <article key={record.id} className="record-card">
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

export default App;
