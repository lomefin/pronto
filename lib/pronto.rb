require 'rugged'
require 'octokit'
require 'forwardable'
require 'httparty'
require 'rainbow'

require 'pronto/error'

require 'pronto/gem_names'

require 'pronto/logger'
require 'pronto/config_file'
require 'pronto/config'

require 'pronto/git/repository'
require 'pronto/git/patches'
require 'pronto/git/patch'
require 'pronto/git/line'

require 'pronto/plugin'
require 'pronto/message'
require 'pronto/comment'
require 'pronto/status'
require 'pronto/runner'
require 'pronto/runners'
require 'pronto/client'
require 'pronto/github'

require 'pronto/formatter/colorizable'
require 'pronto/formatter/base'
require 'pronto/formatter/formatter'
require 'pronto/formatter/text_formatter'
require 'pronto/formatter/json_formatter'
require 'pronto/formatter/git_formatter'
require 'pronto/formatter/commit_formatter'
require 'pronto/formatter/pull_request_formatter'
require 'pronto/formatter/github_formatter'
require 'pronto/formatter/github_status_formatter'
require 'pronto/formatter/github_combined_status_formatter'
require 'pronto/formatter/github_pull_request_formatter'
require 'pronto/formatter/github_pull_request_review_formatter'
require 'pronto/formatter/checkstyle_formatter'
require 'pronto/formatter/null_formatter'

module Pronto
  def self.run(commit = nil, repo_path = '.',
               formatters = [Formatter::TextFormatter.new], file = nil)
    commit ||= default_commit

    repo = Git::Repository.new(repo_path)
    options = { paths: [file] } if file
    patches = repo.diff(commit, options)

    result = Runners.new.run(patches)

    Array(formatters).each do |formatter|
      formatted = formatter.format(result, repo, patches)
      puts formatted if formatted
    end

    result
  end

  def self.default_commit
    Config.new.default_commit
  end
end
