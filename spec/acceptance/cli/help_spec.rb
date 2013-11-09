require 'spec_helper'
require 'appraisal/utils'

describe 'CLI: appraisal help' do
  it 'prints usage along with commands, and list of appraisals' do
    build_appraisal_file <<-Appraisal
      appraise '1.0.0' do
        gem 'dummy', '1.0.0'
      end
    Appraisal

    run_simple 'appraisal help'

    expect(output_from 'appraisal help').to include 'Usage:'
    expect(output_from 'appraisal help').to include 'appraisal [APPRAISAL_NAME] EXTERNAL_COMMAND'
    expect(output_from 'appraisal help').to include '1.0.0'
  end
end
