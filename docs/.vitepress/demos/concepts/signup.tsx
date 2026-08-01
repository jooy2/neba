import { useMemo, useState } from 'react';
import {
  Alert,
  Avatar,
  Blockquote,
  Button,
  Card,
  Checkbox,
  Chip,
  Combobox,
  Container,
  DatePicker,
  Divider,
  FilePicker,
  Grid,
  GridContainer,
  Icon,
  List,
  ListItem,
  NumberField,
  OtpField,
  ProgressLinear,
  Radio,
  RadioGroup,
  Segment,
  SegmentedButton,
  Select,
  Switch,
  TextField,
  Timeline,
  TimelineItem,
  Typography
} from 'neba';

/**
 * Signing up for a product that does not exist.
 *
 * A registration flow is the library's fields with nothing else in the way:
 * every kind of answer a form can ask for — a line of text, a secret, one of a
 * list, a date, a number, a file, a code from a phone — and the states around
 * them. `label`, `description` and `error` are the same three slots on every
 * one of them, which is the whole point of the exercise.
 *
 * The copy stays in English in both locales: it is a code sample, and the prose
 * explaining it lives in the Markdown around the preview.
 */

function LogoIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 1.5 14 5v6l-6 3.5L2 11V5l6-3.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8 8v6.5M8 8l6-3M8 8 2 5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function MailIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect x="2" y="3.5" width="12" height="9" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="m2.75 5 5.25 3.5L13.25 5" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function LockIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <rect x="3" y="7" width="10" height="7" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M5.5 7V5a2.5 2.5 0 0 1 5 0v2" stroke="currentColor" strokeWidth="1.5" />
    </svg>
  );
}

function UserIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="5.5" r="2.75" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M2.75 13.5c.55-2.6 2.7-4.25 5.25-4.25s4.7 1.65 5.25 4.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m3.5 8.5 3 3 6-7"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function AtIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="2.5" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M10.5 8v1.25a2 2 0 0 0 3.25 1.56A6.5 6.5 0 1 0 11 13.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

const STEPS = ['Account', 'Workspace', 'Verify'];

const COUNTRIES = [
  { value: 'kr', label: 'South Korea' },
  { value: 'jp', label: 'Japan' },
  { value: 'de', label: 'Germany' },
  { value: 'us', label: 'United States' },
  { value: 'br', label: 'Brazil' }
];

const ROLES = [
  { value: 'engineering', label: 'Engineering' },
  { value: 'design', label: 'Design' },
  { value: 'product', label: 'Product' },
  { value: 'data', label: 'Data' },
  { value: 'support', label: 'Support' },
  { value: 'ops', label: 'Operations' }
];

const HEARD_FROM = [
  { value: 'search', label: 'Search' },
  { value: 'friend', label: 'A colleague' },
  { value: 'conference', label: 'A conference' },
  { value: 'newsletter', label: 'A newsletter' },
  { value: 'other', label: 'Somewhere else' }
];

const PERKS = [
  '14 days of the Team plan, then Free forever',
  'Unlimited projects while you are trying it',
  'Delete the workspace and everything in it with one click'
];

/** Roughly how strong a password is, on the four rules worth checking. */
function strengthOf(password: string): {
  score: number;
  label: string;
  color: 'danger' | 'warning' | 'success';
} {
  const rules = [
    password.length >= 10,
    /[a-z]/.test(password) && /[A-Z]/.test(password),
    /\d/.test(password),
    /[^\w\s]/.test(password)
  ];
  const score = rules.filter(Boolean).length;

  if (score <= 1) {
    return { score, label: 'Too easy to guess', color: 'danger' };
  }

  if (score === 2 || score === 3) {
    return { score, label: 'Getting there', color: 'warning' };
  }

  return { score, label: 'Strong', color: 'success' };
}

export default function SignupConcept() {
  const [step, setStep] = useState(0);
  const [accountType, setAccountType] = useState<string | number | null>('team');

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [birthday, setBirthday] = useState<Date | null>(null);
  const [country, setCountry] = useState<string | number | null>(null);

  const [workspace, setWorkspace] = useState('');
  const [seats, setSeats] = useState<number | null>(5);
  const [roles, setRoles] = useState<(string | number)[]>(['engineering']);
  const [heardFrom, setHeardFrom] = useState<string | number | null>(null);
  const [plan, setPlan] = useState('team');
  const [logo, setLogo] = useState<File[]>([]);

  const [code, setCode] = useState('');
  const [terms, setTerms] = useState(false);
  const [newsletter, setNewsletter] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);

  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const touch = (field: string) => setTouched((current) => ({ ...current, [field]: true }));

  const emailValid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);
  const slugValid = /^[a-z0-9-]{3,}$/.test(workspace);
  const strength = useMemo(() => strengthOf(password), [password]);

  const errors = {
    name: touched.name && name.trim().length < 2 ? 'Tell us what to call you.' : undefined,
    email: touched.email && !emailValid ? 'That address does not look right.' : undefined,
    password: touched.password && password.length < 10 ? 'At least ten characters.' : undefined,
    workspace:
      touched.workspace && !slugValid
        ? 'Lowercase letters, numbers and hyphens, three or more.'
        : undefined
  };

  const accountReady = name.trim().length >= 2 && emailValid && password.length >= 10;
  const workspaceReady = slugValid && (seats ?? 0) >= 1;
  const verifyReady = code.length === 6 && terms;

  const submit = () => {
    setSubmitting(true);
    setTimeout(() => {
      setSubmitting(false);
      setDone(true);
    }, 900);
  };

  return (
    <Container maxWidth="lg" render={<main />}>
      <div className="flex flex-col gap-6 py-4">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <Icon icon={<LogoIcon />} size="lg" color="primary" label="Kestrel" />
            <Typography level="h6">Kestrel</Typography>
          </div>
          <Typography level="caption" className="text-(--neba-muted-fg)">
            Already have an account?{' '}
            <Button size="xs" variant="text">
              Sign in
            </Button>
          </Typography>
        </div>

        <GridContainer spacing={4} padded={false}>
          {/* The form. One card, one step at a time, and the progress bar above
            it is the only thing that says where you are. */}
          <Grid span={{ xs: 12, md: 7 }}>
            <Card
              className="h-full"
              title={<h2>Create your account</h2>}
              subtitle="Three short steps. Nothing is charged today."
              dividers
              footer={
                <>
                  <Button
                    variant="text"
                    color="secondary"
                    disabled={step === 0 || done}
                    onClick={() => setStep((current) => current - 1)}
                  >
                    Back
                  </Button>
                  <div className="ml-auto flex items-center gap-2">
                    {step < STEPS.length - 1 ? (
                      <Button
                        disabled={step === 0 ? !accountReady : !workspaceReady}
                        onClick={() => setStep((current) => current + 1)}
                      >
                        Continue
                      </Button>
                    ) : (
                      <Button loading={submitting} disabled={!verifyReady || done} onClick={submit}>
                        {done ? 'Workspace ready' : 'Create workspace'}
                      </Button>
                    )}
                  </div>
                </>
              }
            >
              <div className="flex flex-col gap-5">
                <div className="flex flex-col gap-2">
                  <ProgressLinear
                    size="sm"
                    value={((step + 1) / STEPS.length) * 100}
                    label={`Step ${step + 1} of ${STEPS.length} · ${STEPS[step]}`}
                  />
                  <div className="flex items-center gap-2">
                    {STEPS.map((label, index) => (
                      <Chip
                        key={label}
                        size="xs"
                        variant={index === step ? 'solid' : 'text'}
                        color={index < step ? 'success' : index === step ? 'primary' : 'secondary'}
                        startIcon={index < step ? <CheckIcon /> : undefined}
                      >
                        {label}
                      </Chip>
                    ))}
                  </div>
                </div>

                {done && (
                  <Alert color="success" title="You're in">
                    We sent the workspace URL to {email || 'your inbox'}.
                  </Alert>
                )}

                {/* Step one: who you are. Text, a secret, a date, a list. */}
                {step === 0 && (
                  <div className="flex flex-col gap-4">
                    <SegmentedButton
                      fullWidth
                      aria-label="Account type"
                      value={accountType}
                      onValueChange={setAccountType}
                    >
                      <Segment value="personal">Just me</Segment>
                      <Segment value="team">My team</Segment>
                    </SegmentedButton>

                    <TextField
                      fullWidth
                      label="Full name"
                      placeholder="Ada Bell"
                      autoComplete="name"
                      startIcon={<UserIcon />}
                      value={name}
                      onChange={(event) => setName(event.target.value)}
                      onBlur={() => touch('name')}
                      error={errors.name}
                      required
                    />

                    <TextField
                      fullWidth
                      type="email"
                      label="Work email"
                      placeholder="ada@company.com"
                      autoComplete="email"
                      startIcon={<MailIcon />}
                      description="This is where the verification code goes."
                      value={email}
                      onChange={(event) => setEmail(event.target.value)}
                      onBlur={() => touch('email')}
                      error={errors.email}
                      required
                    />

                    <div className="flex flex-col gap-2">
                      <TextField
                        fullWidth
                        type="password"
                        label="Password"
                        autoComplete="new-password"
                        startIcon={<LockIcon />}
                        value={password}
                        onChange={(event) => setPassword(event.target.value)}
                        onBlur={() => touch('password')}
                        error={errors.password}
                        required
                      />
                      {password.length > 0 && (
                        <ProgressLinear
                          size="sm"
                          color={strength.color}
                          value={strength.score}
                          max={4}
                          label={strength.label}
                        />
                      )}
                    </div>

                    <GridContainer spacing={3} padded={false}>
                      <Grid span={{ xs: 12, sm: 6 }}>
                        <DatePicker
                          fullWidth
                          label="Date of birth"
                          placeholder="Pick a day"
                          description="We ask because of local age rules."
                          maxDate={new Date()}
                          value={birthday}
                          onValueChange={setBirthday}
                          clearable
                        />
                      </Grid>
                      <Grid span={{ xs: 12, sm: 6 }}>
                        <Select
                          fullWidth
                          label="Country"
                          placeholder="Choose one"
                          items={COUNTRIES}
                          value={country}
                          onValueChange={setCountry}
                        />
                      </Grid>
                    </GridContainer>
                  </div>
                )}

                {/* Step two: what you are making. A slug, a number, a set, a file. */}
                {step === 1 && (
                  <div className="flex flex-col gap-4">
                    <TextField
                      fullWidth
                      label="Workspace URL"
                      placeholder="northwind"
                      startIcon={<AtIcon />}
                      endIcon={
                        <Typography level="caption" className="text-(--neba-muted-fg)">
                          .kestrel.app
                        </Typography>
                      }
                      description="Lowercase letters, numbers and hyphens."
                      value={workspace}
                      onChange={(event) => setWorkspace(event.target.value.toLowerCase())}
                      onBlur={() => touch('workspace')}
                      error={errors.workspace}
                      required
                    />

                    <NumberField
                      fullWidth
                      label="Seats to start with"
                      description="Add or remove them at any time."
                      min={1}
                      max={200}
                      value={seats}
                      onValueChange={setSeats}
                    />

                    <Combobox
                      multiple
                      fullWidth
                      label="What does your team do?"
                      placeholder="Add a discipline"
                      description="Anything the list does not have is offered as the last row."
                      items={ROLES}
                      value={roles}
                      onValueChange={setRoles}
                    />

                    <RadioGroup
                      label="Plan"
                      value={plan}
                      onValueChange={(value) => setPlan(String(value))}
                    >
                      <Radio value="free" label="Free" description="50k events a month, 3 seats." />
                      <Radio
                        value="team"
                        label="Team — free for 14 days"
                        description="5M events a month, unlimited seats."
                      />
                    </RadioGroup>

                    <Select
                      fullWidth
                      label="How did you hear about us?"
                      placeholder="Optional"
                      items={HEARD_FROM}
                      value={heardFrom}
                      onValueChange={setHeardFrom}
                    />

                    <Divider>Optional</Divider>

                    <FilePicker
                      size="sm"
                      density="compact"
                      accept="image/*"
                      maxSize={2_000_000}
                      maxFiles={1}
                      title="Drop a workspace logo"
                      hint="PNG or SVG · up to 2 MB"
                      value={logo}
                      onFilesChange={setLogo}
                    />
                  </div>
                )}

                {/* Step three: proving the address, and the two consents. */}
                {step === 2 && (
                  <div className="flex flex-col gap-4">
                    <Alert color="info" title="Check your email">
                      A six-digit code is on its way to {email || 'your inbox'}. It expires in ten
                      minutes.
                    </Alert>

                    <OtpField
                      label="Verification code"
                      description="Six digits, from the email we just sent."
                      length={6}
                      groupSize={3}
                      value={code}
                      onValueChange={setCode}
                      error={code.length > 0 && code.length < 6 ? 'Six digits.' : undefined}
                    />

                    <Button size="sm" variant="text" className="self-start">
                      Send it again
                    </Button>

                    <Divider />

                    <Checkbox
                      label="I agree to the terms of service and the privacy notice"
                      description="Both are two pages, and both are in plain language."
                      checked={terms}
                      onCheckedChange={setTerms}
                    />

                    <Switch
                      labelPlacement="start"
                      label="Send me the monthly product note"
                      description="One email a month. Unsubscribe from any of them."
                      checked={newsletter}
                      onCheckedChange={setNewsletter}
                    />
                  </div>
                )}
              </div>
            </Card>
          </Grid>

          {/* The side of the page that is not a form: what you get, who else is
            here, and what happens after the button. */}
          <Grid span={{ xs: 12, md: 5 }}>
            <div className="flex h-full flex-col gap-4">
              <Card variant="solid" color="primary" title="What the free trial includes">
                <List variant="text" size="sm" density="compact">
                  {PERKS.map((perk) => (
                    <ListItem
                      key={perk}
                      startIcon={<Icon icon={<CheckIcon />} size="sm" color="primary" />}
                    >
                      {perk}
                    </ListItem>
                  ))}
                </List>
              </Card>

              <Card size="sm" title="After you sign up">
                <Timeline size="sm" density="compact" active={step + 1} color="primary">
                  <TimelineItem title="Account created" meta="Now" />
                  <TimelineItem title="Workspace named" meta="30 seconds" />
                  <TimelineItem title="Email verified" meta="1 minute" />
                  <TimelineItem title="First event received" meta="Up to you" />
                </Timeline>
              </Card>

              <Blockquote size="sm" variant="outline" author="Jun Park" source="CTO, Acme Rail">
                Signing up took less time than the meeting where we decided to.
              </Blockquote>

              <div className="mt-auto flex items-center gap-2">
                <div className="flex -space-x-2">
                  {['Ada Bell', 'Mira Osei', 'Tom Vale'].map((person) => (
                    <Avatar
                      key={person}
                      size="sm"
                      name={person}
                      color="secondary"
                      className="ring-2 ring-(--neba-bg)"
                    />
                  ))}
                </div>
                <Typography level="caption" className="text-(--neba-muted-fg)">
                  1,208 workspaces created this month
                </Typography>
              </div>
            </div>
          </Grid>
        </GridContainer>
      </div>
    </Container>
  );
}
