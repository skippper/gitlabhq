require 'spec_helper'

describe Gitlab::ChatCommands::IssueSearch, service: true do
  describe '#execute' do
    let!(:issue) { create(:issue, title: 'find me') }
    let!(:confidential) { create(:issue, :confidential, project: project, title: 'mepmep find') }
    let(:project) { issue.project }
    let(:user) { issue.author }
    let(:regex_match) { described_class.match("issue search find") }

    subject do
      described_class.new(project, user).execute(regex_match)
    end

    context 'when the user has no access' do
      it 'only returns the open issues' do
        expect(subject).not_to include(confidential)
      end
    end

    context 'the user has access' do
      before do
        project.team << [user, :master]
      end

      it 'returns all results' do
        expect(subject).to include(confidential, issue)
      end
    end

    context 'without hits on the query' do
      it 'returns an empty collection' do
        expect(subject).to be_empty
      end
    end
  end

  describe 'self.match' do
    let(:query) { "my search keywords" }
    it 'matches the query' do
      match = described_class.match("issue search #{query}")

      expect(match[:query]).to eq(query)
    end
  end
end
