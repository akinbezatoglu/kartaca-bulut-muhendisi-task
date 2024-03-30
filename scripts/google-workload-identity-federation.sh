export PROJECT_ID="project-id"
export PROJECT_NUMBER="project-number"
export SERVICE_ACCOUNT_NAME="service-account-name"
export GITHUB_USR="github-user/org"
export REPO="${GITHUB_USR}/repo-name"

# Create a workload identity pool
gcloud iam workload-identity-pools create "github" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --description="GitHub Actions Pool" \
  --display-name="GitHub Actions Pool"

# Get the full ID of the Workload Identity Pool
gcloud iam workload-identity-pools describe "github" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)"

# Create a Workload Identity Provider in that pool
gcloud iam workload-identity-pools providers create-oidc "github-kartaca" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github" \
  --display-name="Kartaca GitHub Repo Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository =='${REPO}',assertion.repository_owner == '${GITHUB_USR}'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Allow authentications from the Workload Identity Pool to your Google Cloud Service Account.
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${REPO}"