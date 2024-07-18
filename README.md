
# GitHub Estimate App

This GitHub app automatically reminds users to provide an estimate in newly created issues.

## Setup

1. **Clone the repository:**
   ```sh
   git clone your_repo_url
   cd your_repo_name
   ```

2. **Install dependencies:**
   ```sh
   bundle install
   ```

3. **Create a `.env` file:**
   ```sh
   touch .env
   ```

   Add your environment variables to the `.env` file:
   ```env
   GITHUB_APP_IDENTIFIER=your_app_id
   GITHUB_PRIVATE_KEY_PATH=path_to_your_private_key.pem
   WEBHOOK_SECRET=your_webhook_secret
   ```

4. **Run the app:**
   ```sh
   ruby app.rb
   ```

5. **Use Smee.io for webhook forwarding:**
   ```sh
   npx smee-client --url https://smee.io/YOUR_UNIQUE_URL --path /payload --port 4567
   ```

## Usage

- Install the app on a repository.
- Create a new issue.
- If the issue does not contain an estimate in the format `Estimate: X days`, the app will post a reminder comment.
