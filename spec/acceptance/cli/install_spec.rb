require 'spec_helper'
require 'appraisal/utils'

describe 'CLI: appraisal (with no arguments)' do
  it 'runs install command' do
    build_appraisal_file <<-Appraisal
      appraise '1.0.0' do
        gem 'dummy', '1.0.0'
      end
    Appraisal

    run_simple 'appraisal'

    expect(file 'gemfiles/1.0.0.gemfile').to be_exists
    expect(file 'gemfiles/1.0.0.gemfile.lock').to be_exists
  end
end

describe 'CLI: appraisal install' do
  it 'installs the dependencies' do
    build_appraisal_file <<-Appraisal
      appraise '1.0.0' do
        gem 'dummy', '1.0.0'
      end

      appraise '1.1.0' do
        gem 'dummy', '1.1.0'
      end
    Appraisal

    run_simple 'appraisal install'

    expect(file 'gemfiles/1.0.0.gemfile.lock').to be_exists
    expect(file 'gemfiles/1.1.0.gemfile.lock').to be_exists
  end

  it 'relativize directory in gemfile.lock' do
    build_gemspec
    add_gemspec_to_gemfile
    build_appraisal_file <<-Appraisal
      appraise '1.0.0' do
        gem 'dummy', '1.0.0'
      end
    Appraisal

    run_simple 'appraisal install'

    expect(content_of 'gemfiles/1.0.0.gemfile.lock').not_to include current_dir
  end

  context 'with job size', parallel: true do
    before do
      build_appraisal_file <<-Appraisal
        appraise '1.0.0' do
          gem 'dummy', '1.0.0'
        end
      Appraisal
    end

    it 'accepts --jobs option to set job size' do
      run_simple 'appraisal install --jobs=2'

      expect(output_from 'appraisal install --jobs=2').to include
        'bundle install --gemfile=gemfiles/1.0.0.gemfile --jobs=2'
    end

    it 'ignores --jobs option if the job size is less than or equal to 1' do
      run_simple 'appraisal install --jobs=0'

      expect(output_from 'appraisal install --jobs=0').not_to include
        'bundle install --gemfile=gemfiles/1.0.0.gemfile'
      expect(output_from 'appraisal install --jobs=0').not_to include
        'bundle install --gemfile=gemfiles/1.0.0.gemfile --jobs=0'
      expect(output_from 'appraisal install --jobs=0').not_to include
        'bundle install --gemfile=gemfiles/1.0.0.gemfile --jobs=1'
    end
  end
end
