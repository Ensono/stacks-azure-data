#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "ENV_NAME": "$ENV_NAME",
  "ADO_PAT": "$AZDO_PERSONAL_ACCESS_TOKEN",
  "STAGE": $STAGE
}
EOF