@echo off
cd build\web
if errorlevel 1 exit /b 1

git init
git config user.email "deploy@bot.com"
git config user.name "Deploy Bot"
git add .
git commit -m "Deploy to GitHub Pages"
git push --force "https://github.com/otaga/gamefaa.git" master:gh-pages
