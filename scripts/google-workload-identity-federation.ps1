$ProjectId = "project-id"
$ProjectNumber = "project-number"
$ServiceAccountName = "service-account-name"
$GithubUser = "github-user/org"
$Repo = "${GithubUser}/repo-name"

# Create a workload identity pool
gcloud iam workload-identity-pools create "github" `
  --project="$ProjectId" `
  --location="global" `
  --description="GitHub Actions Pool" `
  --display-name="GitHub Actions Pool"

# Get the full ID of the Workload Identity Pool
gcloud iam workload-identity-pools describe "github" `
  --project="$ProjectId" `
  --location="global" `
  --format="value(name)"

# Create a Workload Identity Provider in that pool
gcloud iam workload-identity-pools providers create-oidc "github-kartaca" `
  --project="$ProjectId" `
  --location="global" `
  --workload-identity-pool="github" `
  --display-name="Kartaca GitHub Repo Provider" `
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" `
  --attribute-condition="assertion.repository =='$Repo',assertion.repository_owner == '$GithubUser'" `
  --issuer-uri="https://token.actions.githubusercontent.com"

# Allow authentications from the Workload Identity Pool to your Google Cloud Service Account.
gcloud iam service-accounts add-iam-policy-binding "$ServiceAccountName@$ProjectId.iam.gserviceaccount.com" `
  --project="$ProjectId" `
  --role="roles/iam.workloadIdentityUser" `
  --member="principalSet://iam.googleapis.com/projects/$ProjectNumber/locations/global/workloadIdentityPools/github/attribute.repository/$Repo"
