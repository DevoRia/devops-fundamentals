

git clone https://github.com/EPAM-JS-Competency-center/shop-angular-cloudfront

cd shop-angular-cloudfront




if [ -f ./dist/client-app.zip ]; then
  rm ./dist/client-app.zip
fi


npm install

if [ "$ENV_CONFIGURATION" == "production" ]; then
  npm run build --configuration=production
else
  npm run build
fi

cd dist
zip -r client-app.zip .


