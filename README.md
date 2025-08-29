# DEBUGGA
DEBUGGA is a lightweight, test-driven Ruby debugger built with TracePoint. It is
readable, and extendable.
## Features
- step, next, continue, and basic breakpoint support
- REPL for evaluating expressions in the paused frame
- well-covered engine and breakpoint specs
## Requirements
- Ruby 2.7+ (MRI)
- Bundler
## Quickstart
1. Clone the repo and change directory
```bash
git clone https://github.com/your-username/debugga.git
cd debugga
```

2. Install dependencies
```bash
bundle install
```

3. Make the runner executable (if necessary)
```bash
chmod +x bin/debugr
```

4. Run the example script
```bash
./bin/debugr test_script.rb
```
## Common Commands
- s[tep] - step into next executed line
- n[ext] - step over (next at this call depth)
- c[ontinue] - resume until next breakpoint or program end
- p or eval - evaluate Ruby in the current frame
- b[reak] <file:line> - add breakpoint
- locals - display local variables
- q[uit] - exit debugga
## Run Tests
```bash
bundle exec rspec
```
