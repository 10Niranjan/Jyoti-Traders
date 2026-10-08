import { useEffect, useState } from 'react'
import { useApp } from '../context'
import { Spinner, Input } from '../components'

// ─── Splash ───────────────────────────────────────────────────────────────────

export function Splash() {
  const { navigate } = useApp()
  useEffect(() => {
    const t = setTimeout(() => navigate('signin'), 2200)
    return () => clearTimeout(t)
  }, [navigate])

  return (
    <div className="flex-1 flex flex-col items-center justify-center bg-violet-50 gap-6 fade-in">
      <div className="scale-in flex flex-col items-center gap-4">
        <div className="w-20 h-20 bg-violet-100 rounded-full flex items-center justify-center shadow-sm">
          <span className="text-4xl">🏢</span>
        </div>
        <div className="text-center">
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Jyoti Traders</h1>
          <p className="text-slate-500 text-sm mt-1">Wholesale Market Store</p>
        </div>
      </div>
      <Spinner />
    </div>
  )
}

// ─── Sign In ─────────────────────────────────────────────────────────────────

export function SignIn() {
  const { navigate, setIsAdmin } = useApp()
  const [email, setEmail] = useState('retailer@shop.com')
  const [password, setPassword] = useState('••••••••')
  const [showPass, setShowPass] = useState(false)
  const [loading, setLoading] = useState(false)

  const handleSignIn = () => {
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      setIsAdmin(false)
      navigate('home')
    }, 900)
  }

  const handleAdminDemo = () => {
    setIsAdmin(true)
    navigate('admin-dashboard')
  }

  const handleRetailerDemo = () => {
    setIsAdmin(false)
    navigate('home')
  }

  return (
    <div className="flex-1 flex flex-col items-center justify-center bg-violet-50 px-6 gap-6 fade-in">
      <div className="flex flex-col items-center gap-2">
        <div className="w-16 h-16 bg-violet-100 rounded-full flex items-center justify-center shadow-sm">
          <span className="text-3xl">🏢</span>
        </div>
        <h1 className="text-2xl font-extrabold text-slate-900">Jyoti Traders</h1>
        <p className="text-slate-500 text-sm">Wholesale & Retail Market Hub</p>
      </div>

      <div className="w-full bg-white rounded-2xl p-5 shadow-sm space-y-4">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-600 uppercase tracking-wide">Email Address</label>
          <div className="relative">
            <span className="absolute left-3.5 top-3 text-slate-400 text-sm">✉</span>
            <Input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="pl-9"
              placeholder="retailer@shop.com"
            />
          </div>
        </div>
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-600 uppercase tracking-wide">Password</label>
          <div className="relative">
            <span className="absolute left-3.5 top-3 text-slate-400">🔒</span>
            <Input
              type={showPass ? 'text' : 'password'}
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="pl-9 pr-10"
              placeholder="Enter password"
            />
            <button onClick={() => setShowPass(!showPass)} className="absolute right-3.5 top-3 text-slate-400 text-sm">
              {showPass ? '🙈' : '👁️'}
            </button>
          </div>
        </div>

        <button
          onClick={handleSignIn}
          disabled={loading}
          className="w-full bg-violet-600 hover:bg-violet-700 active:bg-violet-800 text-white font-semibold py-3.5 rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
        >
          {loading ? <><span className="w-5 h-5 rounded-full border-2 border-violet-300 spin border-t-white" />Signing in…</> : 'Sign In'}
        </button>
      </div>

      <p className="text-sm text-slate-500">
        Don't have an account?{' '}
        <button onClick={() => navigate('signup')} className="text-violet-600 font-semibold">Sign Up</button>
      </p>

      <div className="w-full bg-white rounded-2xl p-4 shadow-sm">
        <p className="text-xs text-slate-500 text-center mb-3 font-medium">Simulation Demo Quick Login:</p>
        <div className="flex gap-3">
          <button
            onClick={handleAdminDemo}
            className="flex-1 flex items-center justify-center gap-1.5 bg-violet-600 text-white text-sm font-semibold py-2.5 rounded-xl hover:bg-violet-700 transition-colors"
          >
            <span>🛡️</span> Admin Demo
          </button>
          <button
            onClick={handleRetailerDemo}
            className="flex-1 flex items-center justify-center gap-1.5 border-2 border-violet-600 text-violet-600 text-sm font-semibold py-2.5 rounded-xl hover:bg-violet-50 transition-colors"
          >
            Retailer Demo
          </button>
        </div>
      </div>
    </div>
  )
}

// ─── Sign Up ─────────────────────────────────────────────────────────────────

export function SignUp() {
  const { navigate } = useApp()
  const [form, setForm] = useState({ name: '', phone: '', shop: '', email: '', password: '' })
  const [loading, setLoading] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  const update = (k: string, v: string) => {
    setForm(f => ({ ...f, [k]: v }))
    setErrors(e => ({ ...e, [k]: '' }))
  }

  const validate = () => {
    const errs: Record<string, string> = {}
    if (!form.name.trim()) errs.name = 'Required'
    if (!/^\d{10}$/.test(form.phone.replace(/\s/g, ''))) errs.phone = '10-digit mobile number'
    if (!form.shop.trim()) errs.shop = 'Required'
    if (!form.email.includes('@')) errs.email = 'Valid email required'
    if (form.password.length < 8) errs.password = '8+ chars with upper, lower, number & symbol'
    return errs
  }

  const handleCreate = () => {
    const errs = validate()
    if (Object.keys(errs).length) { setErrors(errs); return }
    setLoading(true)
    setTimeout(() => { setLoading(false); navigate('pending') }, 1000)
  }

  return (
    <div className="flex-1 overflow-y-auto no-scrollbar bg-violet-50">
      <div className="flex flex-col items-center pt-10 pb-8 px-6 gap-5">
        <div className="flex flex-col items-center gap-2">
          <div className="w-14 h-14 bg-violet-100 rounded-full flex items-center justify-center">
            <span className="text-2xl">🏢</span>
          </div>
          <h1 className="text-2xl font-extrabold text-slate-900">Jyoti Traders</h1>
          <p className="text-slate-500 text-sm">Create Your Retailer Account</p>
        </div>

        <div className="w-full bg-white rounded-2xl p-5 shadow-sm space-y-4">
          {[
            { key: 'name', label: 'Full Name', icon: '👤', placeholder: 'Ramesh Sharma', hint: 'Letters and spaces only' },
            { key: 'phone', label: 'Phone Number', icon: '📱', placeholder: '98765 43210', hint: '10-digit mobile number' },
            { key: 'shop', label: 'Business / Shop Name', icon: '🏪', placeholder: 'Sharma General Store', hint: 'Letters, numbers, spaces, & - . allowed' },
            { key: 'email', label: 'Email Address', icon: '✉', placeholder: 'retailer@shop.com', hint: '' },
            { key: 'password', label: 'Password', icon: '🔒', placeholder: '••••••••', hint: '8+ chars with upper, lower, number & symbol' },
          ].map(field => (
            <div key={field.key} className="space-y-1.5">
              <label className="text-xs font-medium text-slate-600 uppercase tracking-wide">{field.label}</label>
              <div className="relative">
                <span className="absolute left-3.5 top-3 text-slate-400">{field.icon}</span>
                <Input
                  type={field.key === 'password' ? 'password' : field.key === 'email' ? 'email' : 'text'}
                  value={form[field.key as keyof typeof form]}
                  onChange={e => update(field.key, e.target.value)}
                  placeholder={field.placeholder}
                  className={`pl-9 ${errors[field.key] ? 'border-red-400 ring-2 ring-red-100' : ''}`}
                />
              </div>
              {errors[field.key]
                ? <p className="text-xs text-red-500">{errors[field.key]}</p>
                : field.hint && <p className="text-xs text-slate-400">{field.hint}</p>
              }
            </div>
          ))}

          <button
            onClick={handleCreate}
            disabled={loading}
            className="w-full bg-violet-600 hover:bg-violet-700 text-white font-semibold py-3.5 rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70 mt-2"
          >
            {loading ? <span className="w-5 h-5 rounded-full border-2 border-violet-300 spin border-t-white" /> : 'Create Account'}
          </button>
        </div>

        <p className="text-sm text-slate-500">
          Already have an account?{' '}
          <button onClick={() => navigate('signin')} className="text-violet-600 font-semibold">Sign In</button>
        </p>
      </div>
    </div>
  )
}

// ─── Pending Approval ─────────────────────────────────────────────────────────

export function PendingApproval() {
  const { navigate } = useApp()
  const [checking, setChecking] = useState(false)

  const handleCheck = () => {
    setChecking(true)
    setTimeout(() => setChecking(false), 1200)
  }

  return (
    <div className="flex-1 flex flex-col items-center justify-center bg-amber-50 px-6 gap-6 fade-in">
      <div className="scale-in flex flex-col items-center gap-5 text-center max-w-xs">
        <div className="w-24 h-24 bg-amber-100 rounded-full flex items-center justify-center">
          <span className="text-5xl">⏳</span>
        </div>
        <div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Account Verification Pending</h2>
          <p className="text-slate-500 text-sm leading-relaxed">
            Your retailer application is currently being reviewed by the owner of Jyoti Traders.
            Once approved, you will gain full access to wholesale product purchasing.
          </p>
        </div>

        <button
          onClick={handleCheck}
          disabled={checking}
          className="w-full bg-violet-600 hover:bg-violet-700 text-white font-semibold py-3.5 rounded-xl transition-colors flex items-center justify-center gap-2"
        >
          {checking
            ? <><span className="w-4 h-4 rounded-full border-2 border-violet-300 spin border-t-white" /> Checking…</>
            : '↺ Check Status Again'
          }
        </button>
      </div>

      <div className="w-full max-w-xs bg-white rounded-2xl p-4 shadow-sm space-y-2">
        <p className="text-xs font-medium text-slate-500 text-center mb-1">Need Urgent Approval? Contact Support</p>
        <a href="tel:+919860460325" className="w-full flex items-center justify-center gap-2 border border-teal-400 text-teal-600 font-medium py-2.5 rounded-xl text-sm hover:bg-teal-50 transition-colors">
          📞 Call Owner: +91 98604 60325
        </a>
        <a href="mailto:vishvatejkatkar007@gmail.com" className="w-full flex items-center justify-center gap-2 border border-violet-400 text-violet-600 font-medium py-2.5 rounded-xl text-sm hover:bg-violet-50 transition-colors">
          ✉ Email: vishvatejkatkar007@gmail.com
        </a>
      </div>

      <button
        onClick={() => navigate('signin')}
        className="text-sm text-red-500 font-medium hover:text-red-600"
      >
        ↩ Sign Out & Try Another Account
      </button>
    </div>
  )
}
