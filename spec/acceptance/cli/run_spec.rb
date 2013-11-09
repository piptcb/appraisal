require 'spec_helper'
require 'appraisal/utils'

describe 'CLI: appraisal (invocation)' do
  before do
    build_appraisal_file <<-Appraisal
      appraise '1.0.0' do
        gem 'dummy', '1.0.0'
      end

      appraise '1.1.0' do
        gem 'dummy', '1.1.0'
      end
    Appraisal

    run_simple 'appraisal install'
    write_file 'test.rb', 'puts "Running: #{$dummy_version}"'
  end

  it 'sets APPRAISAL_INITIALIZED environment variable' do
    write_file 'test.rb', <<-TEST_FILE.strip_heredoc
      if ENV['APPRAISAL_INITIALIZED']
        puts "Appraisal initialized!"
      end
    TEST_FILE

    test_command = 'appraisal 1.0.0 ruby -rbundler/setup -rdummy test.rb'
    run_simple test_command
    expect(output_from test_command).to include 'Appraisal initialized!'
  end

  context 'with appraisal name' do
    it 'runs the given command against a correct versions of dependency' do
      test_command = 'appraisal 1.0.0 ruby -rbundler/setup -rdummy test.rb'
      run_simple test_command

      expect(output_from test_command).to include 'Running: 1.0.0'
      expect(output_from test_command).to_not include 'Running: 1.1.0'
    end

    it 'returns a correct exit status when the commmand fails' do
      write_file 'test.rb', 'puts "Fail: #{$dummy_version}"; raise'
      test_command = 'appraisal 1.0.0 ruby -rbundler/setup -rdummy test.rb'
      run_simple test_command, false

      expect(output_from test_command).to include 'Fail: 1.0.0'
      expect(output_from test_command).to_not include 'Fail: 1.1.0'
      expect(last_exit_status).to eq 1
    end
  end

  context 'without appraisal name' do
    it 'runs the given command against all versions of dependency' do
      test_command = 'appraisal ruby -rbundler/setup -rdummy test.rb'
      run_simple test_command

      expect(output_from test_command).to include 'Running: 1.0.0'
      expect(output_from test_command).to include 'Running: 1.1.0'
    end

    it 'halts when a command return nonzero exit status' do
      write_file 'test.rb', 'puts "Fail: #{$dummy_version}"; raise'
      test_command = 'appraisal ruby -rbundler/setup -rdummy test.rb'
      run_simple test_command, false

      expect(output_from test_command).to include 'Fail: 1.0.0'
      expect(output_from test_command).to_not include 'Fail: 1.1.0'
      expect(last_exit_status).to eq 1
    end
  end
end
