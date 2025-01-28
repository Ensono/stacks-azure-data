#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "ENV_NAME": "$ENV_NAME",
  "ARM_CLIENT_SECRET": "$ARM_CLIENT_SECRET",
  "STAGE": "$STAGE"
}
EOF