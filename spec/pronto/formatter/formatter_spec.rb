module Pronto
  module Formatter
    describe '.register' do
      context 'format method not implementend' do
        subject { Formatter.register(formatter) }

        let(:formatter) do
          Class.new(Pronto::Formatter::Base) do
            def self.name
              'custom_formatter'
            end
          end
        end

        specify do
          -> { subject }.should raise_error(
            NoMethodError, "format method is not declared in the #{formatter.name} class."
          )
        end
      end

      context 'formatter class is not Formatter::Base' do
        subject { Formatter.register(formatter) }

        let(:formatter) do
          Class.new do
            def self.name
              'custom_formatter'
            end

            def format(_messages, _repo, _patches); end
          end
        end

        specify do
          -> { subject }.should raise_error(RuntimeError, "#{formatter.name} is not a #{Pronto::Formatter::Base}")
        end
      end
    end

    describe '.get' do
      context 'single' do
        subject { Formatter.get(name).first }

        context 'github' do
          let(:name) { 'github' }
          it { should be_an_instance_of GithubFormatter }
        end

        context 'github_pr' do
          let(:name) { 'github_pr' }
          it { should be_an_instance_of GithubPullRequestFormatter }
        end

        context 'github_pr_review' do
          let(:name) { 'github_pr_review' }
          it { should be_an_instance_of GithubPullRequestReviewFormatter }
        end

        context 'github_status' do
          let(:name) { 'github_status' }
          it { should be_an_instance_of GithubStatusFormatter }
        end

        context 'json' do
          let(:name) { 'json' }
          it { should be_an_instance_of JsonFormatter }
        end

        context 'text' do
          let(:name) { 'text' }
          it { should be_an_instance_of TextFormatter }
        end

        context 'checkstyle' do
          let(:name) { 'checkstyle' }
          it { should be_an_instance_of CheckstyleFormatter }
        end

        context 'null' do
          let(:name) { 'null' }
          it { should be_an_instance_of NullFormatter }
        end

        context 'empty' do
          let(:name) { '' }
          it { should be_an_instance_of TextFormatter }
        end

        context 'nil' do
          let(:name) { nil }
          it { should be_an_instance_of TextFormatter }
        end
      end

      context 'multiple' do
        subject { Formatter.get(names) }

        context 'github and text' do
          let(:names) { %w[github text] }

          its(:count) { should == 2 }
          its(:first) { should be_an_instance_of GithubFormatter }
          its(:last) { should be_an_instance_of TextFormatter }
        end

        context 'nil and empty' do
          let(:names) { [nil, ''] }

          its(:count) { should == 1 }
          its(:first) { should be_an_instance_of TextFormatter }
        end
      end
    end

    describe '.names' do
      subject { Formatter.names }
      it do
        should =~ %w[github github_pr github_pr_review github_status
                     github_combined_status json checkstyle text null]
      end
    end
  end
end
