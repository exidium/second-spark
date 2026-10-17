# The Second Spark

A solo browser adaptation of *Abomination: The Heir of Frankenstein*: one human against 1 to 3 AI rivals in 1819 Paris. A personal fan project. Mechanics and numbers follow the physical game; names, wording and art are original.

Play it: https://exidium.github.io/second-spark/

Build and test:
```
python3 build.py        # writes dist/second-spark.html from src/
npm install             # once, for Playwright
npm run test:sim        # 20 AI-only games
npm run test:ui         # plays a full game through the UI, checks 400px width
npm run deploy          # rebuilds and pushes dist/ to the gh-pages branch (GitHub Pages)
```
See `docs/SPEC.md` for the rules as built and `docs/DECISIONS.md` for why.
