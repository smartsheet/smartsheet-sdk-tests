#!/usr/bin/env sh

PACKAGE_NAME=$1
WIREMOCK_JAR=$2
DATA_SCENARIO_DIR='data/scenarios'
LAUNCH_SCRIPT='data/launch.sh'
PACKAGE_README='data/README.md'
STUB_DEFAULTS='data/stub_defaults.json'

INVALID_INPUT=0
if [ -z $PACKAGE_NAME ]; then
    echo 'Package name must be specified'
    INVALID_INPUT=1
fi

if [ ! -f $SCENARIO ]; then
    echo 'Could not find scenario file'
    INVALID_INPUT=1
fi

if [ -z $WIREMOCK_JAR ] || [ ! -f $WIREMOCK_JAR ]; then
    echo 'Could not find wiremock JAR'
    INVALID_INPUT=1
fi

USAGE_TEXT="Usage: ./$0 package-name wiremock-jar"
if [ $INVALID_INPUT == 1 ]; then
    echo $USAGE_TEXT
    exit 1
fi

PACKAGE_MAPPINGS_DIR="$PACKAGE_NAME/mappings/"
PACKAGE_SCENARIO_DIR="$PACKAGE_NAME/__files/__scenarios/"
PACKAGE_SCENARIOS="$PACKAGE_SCENARIO_DIR/scenarios.json"
TMP_SCENARIOS=".tmp_scenarios.json"

# make wiremock root directory
mkdir -p $PACKAGE_SCENARIO_DIR
mkdir -p $PACKAGE_MAPPINGS_DIR

# add scenario and apply defaults
node concat_scenarios.js --scenarios="$DATA_SCENARIO_DIR" --output="$TMP_SCENARIOS"
ruby apply_defaults.rb --output $PACKAGE_SCENARIOS $STUB_DEFAULTS $TMP_SCENARIOS 
rm $TMP_SCENARIOS

# add mappings
ruby gen_mappings.rb $PACKAGE_SCENARIOS $PACKAGE_MAPPINGS_DIR

# add readme
cp $PACKAGE_README "$PACKAGE_NAME/README.md"
ruby gen_docs.rb $PACKAGE_SCENARIOS >> "$PACKAGE_NAME/README.md"

# add wiremock JAR
cp $WIREMOCK_JAR "$PACKAGE_NAME/wiremock.jar"

# add launch script
cp $LAUNCH_SCRIPT "$PACKAGE_NAME/launch.sh"

# create zip
(cd $PACKAGE_NAME; zip -q -r "$PACKAGE_NAME.zip" *)
mv "$PACKAGE_NAME/$PACKAGE_NAME.zip" .
