# BrightOS Implementation Plan

## Planning Principles

As a general rule (with possible exceptions):

1. Prioritise needs of disabled users over developer convenience or platform
   completeness.
2. Prioritise user safety and accessibility outcomes before infrastructure or
   packaging improvements.
3. Prefer changes that can be verified automatically in Molecule.
4. Keep each iteration narrow enough to implement, review, and test in one PR.

## Priority Order

### P0: Define and verify disability-critical outcomes

This repository has strong stated goals around accessibility and safety, but the
current verification layer does not test those outcomes.

#### 1. Replace placeholder verification with real assertions

STATUS: COMPLETE.

Why this matters:
Users with learning difficulties and other disabilities need dependable,
repeatable system behaviour. Presently, the verify playbook does not catch
regressions in safety or accessibility controls.

Current gap:

- [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)
  only contained a trivial assertion.

Implementation tasks:

- Add verification tasks for required services and files.
- Assert protective DNS configuration is applied.
- Assert firewall configuration is present and active where supported.
- Assert proxy configuration is installed when enabled.
- Assert required accessibility-oriented packages are present.
- Assert intentionally hidden or disallowed applications remain hidden or
  absent.

Likely files:
- [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)
- [roles/network/tasks/main.yml](../roles/network/tasks/main.yml)
- [roles/firewall/tasks/main.yml](../roles/firewall/tasks/main.yml)
- [roles/proxy/tasks/main.yml](../roles/proxy/tasks/main.yml)
- [roles/gui_packages/tasks/main.yml](../roles/gui_packages/tasks/main.yml)

Definition of done:

- `molecule verify` fails when a safety or accessibility control regresses.
- Verification checks reflect actual BrightOS expectations rather than generic
  host health.

#### 2. Turn accessibility goals into concrete acceptance criteria

Why this matters:
The project explicitly targets fine motor limitations, mild vision impairment,
and learning difficulties, but those needs are not yet translated into
actionable engineering requirements.

Current gap:
- [docs/Accessibility.md](../docs/Accessibility.md) describes intent, not testable
  standards.

Implementation tasks:
- Define minimum supported experience for each target need category.
- Identify which settings, apps, or restrictions implement each requirement.
- Mark which requirements are mandatory for every install and which are
  optional profiles.
- Link each requirement to a verification check where possible.

Likely files:
- [docs/Accessibility.md](../docs/Accessibility.md)
- [docs/Features.md](../docs/Features.md)
- [docs/Security.md](../docs/Security.md)
- [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)

Definition of done:
- Accessibility requirements can be used as acceptance criteria during PR
  review.
- Each requirement is either automated, manually testable, or explicitly marked
  as future work.

#### 3. Complete protective DNS support for RedHat-family systems

Why this matters:
DNS controls are one of the few current mechanisms explicitly aimed at
protecting vulnerable users from harmful content.

Current gap:
- RedHat implementation remains a TODO in
  [roles/network/tasks/main.yml](../roles/network/tasks/main.yml).

Implementation tasks:
- Implement RedHat DNS override using the supported NetworkManager keyfile or
  equivalent mechanism.
- Ensure the task is idempotent.
- Ensure handler behaviour is safe in non-systemd/container environments.
- Add verify coverage for both Debian and RedHat paths.

Likely files:
- [roles/network/tasks/main.yml](../roles/network/tasks/main.yml)
- [roles/network/tasks/RedHat.yml](../roles/network/tasks/RedHat.yml) if created
- [roles/network/handlers/main.yml](../roles/network/handlers/main.yml)
- [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)

Definition of done:
- DNS override works on both supported OS families.
- Molecule or equivalent validation covers the expected resulting config.

### P1: Restore feature parity for supported platforms

#### 4. Add a RedHat-family Molecule scenario

Why this matters:
RedHat-specific verification and role logic cannot be trusted if they are never
executed in automated tests. At present, the default Molecule scenario only
covers Ubuntu.

Current gap:
- RedHat verification paths exist or are planned, but no Molecule scenario runs
  them automatically.

Implementation tasks:
- Add a RedHat-family Molecule scenario using a supported target image.
- Reuse the shared playbooks where practical so Debian and RedHat scenarios
  validate the same core expectations.
- Ensure the scenario is suitable for firewall, network, and GUI package
  verification work.
- Update test documentation to include the new scenario.

Likely files:
- [molecule/](../molecule)
- [molecule/resources/playbooks/converge.yml](../molecule/resources/playbooks/converge.yml)
- [molecule/resources/playbooks/verify.yml](../molecule/resources/playbooks/verify.yml)
- [docs/Testing.md](../docs/Testing.md)

Definition of done:
- RedHat-family role paths run in Molecule.
- Verification changes for RedHat can be exercised before merge.

#### 5. Resolve RedHat GUI package blockers

Why this matters:
Accessible and educational desktop software is part of the user value of
BrightOS. Missing apps on one supported OS family weakens that promise.

Current gap:
- Snap and squashfs-related TODOs remain in
  [roles/gui_packages/tasks/RedHat.yml](../roles/gui_packages/tasks/RedHat.yml).

Implementation tasks:
- Decide whether Snap is the correct delivery mechanism on AlmaLinux.
- If yes, resolve the squashfs/module issue in an idempotent, supportable way.
- If no, replace Snap-based apps with supported RPM, Flatpak, or alternative
  packages.
- Reassess package choices against accessibility goals rather than package
  availability alone.

Likely files:
- [roles/gui_packages/tasks/RedHat.yml](../roles/gui_packages/tasks/RedHat.yml)
- [docs/Features.md](../docs/Features.md)
- [docs/Accessibility.md](../docs/Accessibility.md)

Definition of done:
- RedHat-family installations deliver a defined minimum accessible app set.
- The package path is automated and testable.

#### 6. Define a minimum supported application set for target users

Why this matters:
The project goal is not just to configure Linux, but to make it usable and
beneficial for vulnerable users.

Current gap:
- The repository references some packages and apps, but there is no explicit
  baseline application profile tied to user needs.

Implementation tasks:
- Define the minimum app set by disability/user need category.
- Identify unsupported, distracting, or unsafe applications to hide or remove.
- Document the rationale for each included app.
- Add verification for presence or absence of those apps where feasible.

Likely files:
- [roles/gui_packages/tasks/main.yml](../roles/gui_packages/tasks/main.yml)
- [roles/packages/tasks/main.yml](../roles/packages/tasks/main.yml)
- [docs/Features.md](../docs/Features.md)
- [docs/Accessibility.md](../docs/Accessibility.md)

Definition of done:
- There is an explicit baseline app profile that can be reviewed with carers or
  testers.
- Package selection decisions are traceable to user needs.

### P1: Make the project easier for carers and contributors to use safely

#### 7. Expand installation documentation for non-experts

Why this matters:
If carers or helpers cannot install or validate the system reliably, the
project remains inaccessible to many of the people it aims to help.

Current gap:
- [docs/INSTALL.md](../docs/INSTALL.md) explicitly says it needs expansion.

Implementation tasks:
- Turn the current brief list into a complete step-by-step guide.
- Add a short validation checklist after installation.
- Call out decisions that matter for disabled-user safety, such as DNS,
  browser, and user account configuration.
- Link to testing and Windows/WSL guidance where appropriate.

Likely files:
- [docs/INSTALL.md](../docs/INSTALL.md)
- [docs/Testing.md](../docs/Testing.md)
- [docs/Windows development.md](../docs/Windows%20development.md)

Definition of done:
- A new contributor or carer can complete installation without guessing hidden
  steps.
- The guide includes a post-install confirmation checklist.

#### 8. Add CI to protect critical behaviour automatically

Why this matters:
Once disability-critical checks exist, they should run automatically so they do
not depend on manual vigilance.

Current gap:
- Mission-level CI/CD goals exist, but no visible repository automation is in
  place.

Implementation tasks:
- Add CI for lint plus default Molecule scenario.
- Run verification assertions as part of the gated workflow.
- Keep CI scope small enough to stay reliable.
- Treat accessibility and safety regressions as blocking failures.

Likely files:
- `.github/workflows/*`
- [docs/Mission.md](../docs/Mission.md)
- [docs/Testing.md](../docs/Testing.md)

Definition of done:
- PRs automatically run the baseline validation path.
- Core safety and accessibility regressions are caught before merge.

### P2: Resolve secondary backlog items

#### 9. Decide whether hostname/domain support is in scope

Current gap:
- [roles/name/tasks/main.yml](../roles/name/tasks/main.yml) contains an open TODO
  about domain support.

Implementation tasks:
- Decide whether domain configuration helps real BrightOS deployments.
- Either implement it cleanly or remove the dead/commented code.

Definition of done:
- The role reflects an intentional decision rather than an unresolved comment.

#### 10. Break down ISO/distribution pipeline work into staged milestones

Why this matters:
This is important for long-term adoption by non-technical users, but it should
not displace more immediate accessibility and safety improvements.

Current gap:
- [docs/Mission.md](../docs/Mission.md) lists ISO generation as a future goal,
  but not as an actionable roadmap.

Implementation tasks:
- Separate image-building, installer flow, and distribution hosting into
  distinct milestones.
- Identify what must already be stable before ISO work starts.

Definition of done:
- The distribution goal is represented as an ordered backlog, not a single
  large TODO.

## Recommended Iteration Sequence

1. Real verification assertions.
2. Accessibility acceptance criteria.
3. RedHat DNS parity.
4. RedHat Molecule scenario.
5. RedHat accessible app path.
6. Minimum supported application set.
7. Expanded installation guide.
8. CI for baseline validation.
9. Hostname/domain decision.
10. ISO pipeline milestones.

## Working Rule For Future Iterations

When choosing between two backlog items of similar effort, prefer the one that
most directly improves one of these outcomes:

1. Safety for vulnerable users.
2. Accessibility for the intended user groups.
3. Reliability of those protections through automated verification.
