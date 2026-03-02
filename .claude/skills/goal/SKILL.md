---
name: Goal Manager
description: "Set, update, review, or complete goals. Works with @coach (life goals) and @ceo (business goals)."
user_invocable: true
command: /goal
---

# /goal — Goal Manager

## Usage
- `/goal` → show active goals
- `/goal set [description]` → set a new goal
- `/goal update [#] [progress note]` → update progress
- `/goal done [#]` → mark goal as completed
- `/goal review` → full goal review with progress

If user provides a goal without subcommand → treat as `/goal set`.

## Protocol

### Show goals (default — no args)
1. Read `state/goals.md`
2. If no active goals → "Nie masz jeszcze celów. Chcesz ustawić pierwszy?"
3. If goals exist → display active goals as compact list:
```
🎯 Twoje cele:

#1 [Goal] — [status] ([progress])
#2 [Goal] — [status] ([progress])
```
4. Quick Actions: "Zaktualizuj cel" / "Dodaj nowy" / "OK"

### Set goal
1. If description provided → use it. If not → ask: "Jaki cel chcesz ustawić?"
2. Auto-detect category from content:
   - Business/work/revenue/clients → business → owner: @ceo
   - Health/fitness/weight/exercise → health → owner: @coach
   - Learning/skill/language/read → learning → owner: @teacher or @mentor
   - Life/habit/routine/relationship → life → owner: @coach
3. Use `AskUserQuestion` for target date:
   - header: "Termin"
   - options: "1 tydzień" / "1 miesiąc" / "3 miesiące" / "6 miesięcy"
4. Add to `state/goals.md → Active Goals` table
5. If goal has clear sub-steps → auto-generate 2-3 milestones in Milestones table
6. Confirm: "Cel ustawiony. [Owner agent] będzie Cię wspierać."

### Update goal
1. Read `state/goals.md`, find goal by #
2. Update Progress column with note
3. If progress suggests completion → ask: "Wygląda na to, że cel osiągnięty. Zamknąć?"
4. Post to context-bus: `@goal-owner → all: Goal #[X] updated — [progress]`

### Complete goal
1. Move from Active Goals to Completed Goals with date and duration
2. Post to context-bus: `@coach → all: 🎉 Goal completed — [goal description]`
3. Celebrate: "Powiedziałeś, że to zrobisz. Zrobiłeś. To jest ogromne."
4. Ask: "Chcesz ustawić następny cel?" (AskUserQuestion)

### Review
1. Read all active goals with milestones
2. For each goal: calculate time elapsed vs target, show progress
3. Flag goals at risk (>50% time elapsed, <25% progress)
4. Suggest adjustments for struggling goals
5. End with: "Jeden cel, który zasługuje na Twój fokus w tym tygodniu: [most impactful]"

## ADHD Adaptation

Read `profile.md` → `adhd_indicators` before all goal operations.

**If adhd_indicators = yes/suspected:**

### Show goals
- Frame goals as challenges, not obligations: "🎯 Twoje wyzwania:" instead of "Twoje cele:"
- Show streak counters: "Streak: [X] dni aktywnego postępu"
- Max 2 visible goals. If more exist: "Masz [X] celów — te 2 są teraz najważniejsze."

### Set goal
- Add dopamine hook: "Nowe wyzwanie przyjęte! 🔥 Pierwszy milestone za [X] dni."
- Auto-generate shorter milestones (1-2 weeks instead of months) for quicker wins
- Frame target dates as countdowns: "Challenge: [goal] w [X] dni. Start!"

### Update goal
- Celebrate every update loudly: "📈 Postęp! [progress bar ████░░░░ 40%]. Nie zatrzymuj się!"
- If progress milestone hit → extra celebration: "🏆 MILESTONE! [description]. To jest ogromne."

### Complete goal
- Maximum celebration: "🎉🎉🎉 WYZWANIE UKOŃCZONE! [goal]. Powiedziałeś, zrobiłeś. LEGENDA."
- Show total streak/time: "Od startu do mety: [X] dni. [Y] aktualizacji. Konsekwencja = sukces."

### Review
- Show progress bars visually (████░░░░)
- Focus on wins first, risks second
- End with challenge framing: "Wyzwanie tygodnia: [most impactful goal action]"

## State Files
- **Read:** state/goals.md, profile.md (primary_goal, adhd_indicators)
- **Write:** state/goals.md (Active Goals, Milestones, Completed Goals)

## Agents
- @coach owns life/health goals
- @ceo owns business goals
- @teacher/@mentor own learning/career goals
