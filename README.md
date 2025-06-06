# My Projects

A super simple dashboard that pulls data about all my GitHub repositories and presents it in one place for a high-level overview of everything I'm working on.

## Features

- Lists all repositories from a GitHub user account
- Display, sort and filter your projects by:
  - Repo name, description, URL
  - Languages used
  - Creation and last pushed dates
  - Priority
  - Status
  - Your motivation to work on it
  - Type of project
- Uses JSON for data storage
- Basic auth for private use only

## Architecture

Built to be lightweight and maintainable:

- [Sinatra](https://sinatrarb.com/)
- [Rack](https://github.com/rack/rack)
- `Rack::Auth::Basic`
- ERB templates
- GitHub REST API v3 - fetch data about your repos from GitHub
- JSON for data storage — no database complexity

## Setup

### Prerequisites

- Ruby 3.x
- Bundler
- GitHub personal access token (with `repo` scope)
- NGINX or similar reverse proxy (optional but recommended)

### Installation

```bash
git clone https://github.com/benschem/my-projects-dashboard.git
cd my-projects-dashboard
bundle install
```

### Environment setup

Create a `.env` file following the `.env.example` example.

Add your Github username and token.

### Running the app

```bash
rackup
```

For for hot reloading of the whole app in development, use

```bash
rerun -- rackup
```

By default, the app runs on http://localhost:9292

## Deployment

Designed to run behind NGINX on a VPS.

A simple setup includes:

- Setting up Ruby, Bundler, and dependencies
- Using systemd to run rackup as a service
- Configuring NGINX as a reverse proxy
- Securing with HTTPS using Let’s Encrypt (optional but recommended)

## Possible Stretch Goals

- Add screenshots of apps
- Add OpenAI summaries of each project
- Turbo/Stimulus to update pages without refreshing

## License

MIT License
