import { useState, useEffect } from 'react';
import './App.css';

const features = [
  {
    icon: '🩸',
    title: 'Track Donations',
    description: 'Monitor your donation history, streaks, and milestones in real time.',
  },
  {
    icon: '📅',
    title: 'Book Appointments',
    description: 'Schedule your next donation at a partner hospital with a few taps.',
  },
  {
    icon: '🔔',
    title: 'Stay Notified',
    description: 'Get alerts on donation milestones, eligibility, and appointment reminders.',
  },
  {
    icon: '🛡️',
    title: 'Admin Dashboard',
    description: 'Manage donors, approve donations, and monitor activity from one view.',
  },
  {
    icon: '🔥',
    title: 'Streak System',
    description: 'Earn streaks for every approved donation and stay motivated to save lives.',
  },
  {
    icon: '🔐',
    title: 'Secure Auth',
    description: 'Google Sign-In and email authentication powered by Supabase.',
  },
];

const techStack = [
  { name: 'Flutter', icon: '📱', desc: 'Cross-platform UI' },
  { name: 'Supabase', icon: '⚡', desc: 'Backend & Auth' },
  { name: 'PostgreSQL', icon: '🗄️', desc: 'Database' },
  { name: 'Provider', icon: '🔄', desc: 'State Management' },
];

const stats = [
  { value: '5', label: 'Core Screens' },
  { value: '4', label: 'Blood Types' },
  { value: '∞', label: 'Lives Saved' },
  { value: '24/7', label: 'Availability' },
];

function App() {
  const [scrollY, setScrollY] = useState(0);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="app">
      {/* Hero Section */}
      <header className="hero">
        <div className="hero-bg" style={{ transform: `translateY(${scrollY * 0.3}px)` }} />
        <div className="hero-overlay" />
        <nav className="nav">
          <div className="nav-brand">
            <span className="nav-icon">🩸</span>
            <span className="nav-title">Blood Donation</span>
          </div>
          <a
            href="https://github.com/DaudiKi/BloodDonationApp_Flutter"
            target="_blank"
            rel="noopener noreferrer"
            className="nav-link"
          >
            GitHub →
          </a>
        </nav>

        <div className={`hero-content ${isVisible ? 'visible' : ''}`}>
          <div className="hero-badge animate-in delay-1">
            <span className="badge-dot" />
            Flutter Mobile App
          </div>
          <h1 className="hero-title animate-in delay-2">
            Save Lives,<br />
            <span className="hero-accent">Donate Blood</span>
          </h1>
          <p className="hero-subtitle animate-in delay-3">
            A premium cross-platform mobile application for managing blood donations, 
            booking appointments, and tracking your life-saving journey.
          </p>
          <div className="hero-actions animate-in delay-4">
            <a
              href="https://github.com/DaudiKi/BloodDonationApp_Flutter"
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary"
            >
              View on GitHub
            </a>
            <a href="#features" className="btn btn-secondary">
              Explore Features
            </a>
          </div>
        </div>

        <div className="hero-visual animate-in delay-5">
          <div className="phone-mockup">
            <div className="phone-screen">
              <div className="mock-header">
                <div className="mock-title">🩸 Blood Donation</div>
              </div>
              <div className="mock-card">
                <div className="mock-avatar">D</div>
                <div className="mock-info">
                  <div className="mock-name">Donor Dashboard</div>
                  <div className="mock-email">donor@example.com</div>
                </div>
                <div className="mock-streak">
                  <span className="streak-fire">🔥</span>
                  <span className="streak-num">5</span>
                </div>
              </div>
              <div className="mock-list">
                <div className="mock-item">
                  <span className="mock-dot approved" />
                  <span>Donation — A+</span>
                  <span className="mock-badge">Approved</span>
                </div>
                <div className="mock-item">
                  <span className="mock-dot pending" />
                  <span>Donation — O-</span>
                  <span className="mock-badge pending-badge">Pending</span>
                </div>
                <div className="mock-item">
                  <span className="mock-dot approved" />
                  <span>Appointment</span>
                  <span className="mock-badge">Scheduled</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Stats Section */}
      <section className="stats-section">
        <div className="stats-grid">
          {stats.map((stat, i) => (
            <div key={i} className={`stat-card animate-in delay-${i + 1}`}>
              <span className="stat-value">{stat.value}</span>
              <span className="stat-label">{stat.label}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="features-section">
        <div className="section-header animate-in">
          <span className="section-tag">Features</span>
          <h2 className="section-title">Everything you need to manage donations</h2>
          <p className="section-subtitle">
            Built with care for both donors and administrators
          </p>
        </div>
        <div className="features-grid">
          {features.map((feature, i) => (
            <div key={i} className={`feature-card animate-in delay-${i + 1}`}>
              <div className="feature-icon">{feature.icon}</div>
              <h3 className="feature-title">{feature.title}</h3>
              <p className="feature-desc">{feature.description}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Tech Stack Section */}
      <section className="tech-section">
        <div className="section-header animate-in">
          <span className="section-tag">Tech Stack</span>
          <h2 className="section-title">Built with modern technologies</h2>
        </div>
        <div className="tech-grid">
          {techStack.map((tech, i) => (
            <div key={i} className={`tech-card animate-in delay-${i + 1}`}>
              <span className="tech-icon">{tech.icon}</span>
              <span className="tech-name">{tech.name}</span>
              <span className="tech-desc">{tech.desc}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Design Section */}
      <section className="design-section">
        <div className="section-header animate-in">
          <span className="section-tag">Design</span>
          <h2 className="section-title">Premium Deep Red & Cream</h2>
          <p className="section-subtitle">
            A carefully crafted color system for trust and warmth
          </p>
        </div>
        <div className="color-palette animate-in delay-2">
          <div className="color-swatch deep-red-swatch">
            <span className="swatch-name">Deep Red</span>
            <span className="swatch-hex">#B31A1A</span>
          </div>
          <div className="color-swatch dark-red-swatch">
            <span className="swatch-name">Dark Red</span>
            <span className="swatch-hex">#8B1414</span>
          </div>
          <div className="color-swatch cream-swatch">
            <span className="swatch-name">Cream</span>
            <span className="swatch-hex">#FAF5E6</span>
          </div>
          <div className="color-swatch light-red-swatch">
            <span className="swatch-name">Light Red</span>
            <span className="swatch-hex">#E6B3B3</span>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-brand">
            <span className="footer-icon">🩸</span>
            <span className="footer-title">Blood Donation App</span>
          </div>
          <p className="footer-text">
            A Flutter mobile application — saving lives, one donation at a time.
          </p>
          <div className="footer-links">
            <a
              href="https://github.com/DaudiKi/BloodDonationApp_Flutter"
              target="_blank"
              rel="noopener noreferrer"
              className="footer-link"
            >
              GitHub
            </a>
            <span className="footer-divider">·</span>
            <span className="footer-link">Flutter</span>
            <span className="footer-divider">·</span>
            <span className="footer-link">Supabase</span>
          </div>
          <p className="footer-copyright">
            © {new Date().getFullYear()} Blood Donation App. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}

export default App;
