DOCKER_IMAGE='central-settlement'
DOCKER_TAG='test'
DOCKER_FILE="test-integration.Dockerfile"
DOCKER_WORKING_DIR="/opt/central-settlement"
DOCKER_NETWORK="integration-test-net"

DB_USER="central_ledger"
DB_PASSWORD="cVq8iFqaLuHy8jjKuA"
DB_HOST="db-int"
DB_PORT=3306
DB_NAME="central_ledger_integration"
DB_IMAGE="mysql/mysql-server"
DB_TAG="5.7"

KAFKA_IMAGE='spotify/kafkaproxy'
KAFKA_HOST="kafka-int"
KAFKA_ZOO_PORT="2181"
KAFKA_BROKER_PORT="9092"

APP_HOST="central-settlement-int"

INTEGRATION_DIR="integration"
RESULT_DIR="results"

TEST_DIR="test"

APP_DIR_TEST_INTEGRATION="$TEST_DIR/$INTEGRATION_DIR"
APP_DIR_TEST_RESULTS="$TEST_DIR/$RESULT_DIR"
TEST_RESULTS_FILE="tape-integration.xml"

TEST_CMD="mkdir -p $APP_DIR_TEST_RESULTS; tape '${APP_DIR_TEST_INTEGRATION}/**/*.test.js' | tap-xunit > $APP_DIR_TEST_RESULTS/$TEST_RESULTS_FILE"

SIMULATOR_HOST="simulator-int"
SIMULATOR_PORT="8444"
SIMULATOR_IMAGE='mojaloop/simulator'
# SIMULATOR_IMAGE='ldaly/simulator'
# SIMULATOR_IMAGE_TAG='v6.2.5'
# SIMULATOR_IMAGE_TAG='0.1.0'
SIMULATOR_IMAGE_TAG='latest'
SIMULATOR_REMOTE_HOST="simulator-int"
SIMULATOR_REMOTE_PORT="8444"
CENTRAL_LEDGER_HOST="central-ledger-int"
CENTRAL_LEDGER_PORT="3001"
CENTRAL_LEDGER_IMAGE='mojaloop/central-ledger'
# CENTRAL_LEDGER_IMAGE='ldaly/central-ledger'
# CENTRAL_LEDGER_TAG='0.1.3'
CENTRAL_LEDGER_TAG='latest'
# CENTRAL_LEDGER_TAG='v6.3.0-snapshot'
ML_API_ADAPTER_HOST="ml-api-adapter-int"
ML_API_ADAPTER_PORT="3000"
ML_API_ADAPTER_IMAGE='mojaloop/ml-api-adapter'
# ML_API_ADAPTER_TAG='v6.4.0'
# ML_API_ADAPTER_TAG='v7.1.0' - not working
ML_API_ADAPTER_TAG='latest'

