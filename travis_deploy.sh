# travis only does a shallow clone by default
git fetch --unshallow

# make the premake binary available (the package script expects it in $PATH)
export PATH=$PATH:$(pwd)/build/bootstrap

# run the package script
premake5 package $TRAVIS_BRANCH $DEPLOY noprompt

# work out the filename
if [ $BUILD = "mingw" ]; then
	EXT="zip"
else
	EXT="tar.gz"
fi
if [ $DEPLOY = "binary" ]; then
	export BUILDNAME=premake-$TRAVIS_BRANCH-$BUILD.$EXT
else
	export BUILDNAME=premake-$TRAVIS_BRANCH-src.zip
fi

# and let Travis deploy it
echo "Deploying $BUILDNAME..."
