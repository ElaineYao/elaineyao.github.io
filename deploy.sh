zola build
cd public
git init
git remote add deploy git@github.com:ElaineYao/elaineyao.github.io.git
git add .
git commit -m "Deploy $(date)"
git branch -M gh-pages
git push -f deploy gh-pages