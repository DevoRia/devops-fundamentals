cd shop-angular-cloudfront

npm run lint


npm run test
if [ $? -ne 0 ]; then
  echo "Unit tests failed"
  exit 1
fi


npm audit --json > audit.json
if [ -s audit.json ]; then
  echo "Audit failed, see audit.json for details"
  exit 1
else
  rm audit.json
fi

echo "Quality check passed"

cd ..
