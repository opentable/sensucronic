require "spec_helper"

describe Sensucronic do

  it "has a version number" do
    expect(Sensucronic::VERSION).not_to be nil
  end

  describe '#report' do
    let(:report)     { subject.report     }
    let(:status)     { report[:status]    }
    let(:output)     { report[:output]    }
    let(:exitcode)   { report[:exitcode]  }
    let(:exitsignal) { report[:exitsignal]}
    let(:argv)       { cmd.kind_of?(Array) ? cmd : [cmd] }

    before do
      subject.parse_options(argv)
      subject.run
    end

    context 'given a command that exits true' do
      let(:cmd) { %w{ echo hi } }

      it { expect(output).to eq "hi\n" }
      it { expect(exitcode).to eq 0 }
      it { expect(status).to eq 0 }
      it { expect(report[:source]).to be_nil }
    end

    context 'given a command that exits false' do
      let(:cmd) { %w{ false } }

      it { expect(output).to eq "" }
      it { expect(exitcode).to eq 1 }
      it { expect(status).to eq 1 }
    end

    context 'given a command that exits critical' do
      let(:cmd) { ['exit 2'] }

      it { expect(output).to eq "" }
      it { expect(exitcode).to eq 2 }
      it { expect(status).to eq 2 }
    end

    context 'given a command that exits on signal 15' do
      let(:cmd) { 'kill -15 $$' }

      it { expect(output).to match(/signal 15/) }
      it { expect(exitcode).to eq 128 + 15 }
      it { expect(status).to eq 3 }
    end

    context 'given a command that exits on signal 9' do
      let(:cmd) { 'kill -9 $$' }

      it { expect(output).to match(/signal 9/) }
      it { expect(exitcode).to eq 128 + 9 }
      it { expect(status).to eq 3 }
    end

    context 'command with stderr and stdout' do
      let(:cmd) { 'echo stderr >&2; echo stdout' }

      it { expect(output).to eq "stdout\n\nstderr\n" }
      it { expect(status).to eq 0 }
    end

    context 'with --source cli option' do
      let(:cmd) { %w{ --source foo.com echo hi } }
      it 'should set the source attribute' do
        expect(report[:source]).to eq "foo.com"
      end
      it { expect(output).to eq "hi\n" }
    end

  end

end
