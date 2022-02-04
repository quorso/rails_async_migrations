RSpec.describe RailsAsyncMigrations::Workers do
  let(:called_worker) { :check_queue }
  let(:instance) { described_class.new(called_worker) }
  let(:args) { [] }
  let(:async_schema_migration) do
    AsyncSchemaMigration.create!(
      version: '00000',
      direction: 'up',
      state: 'created'
    )
  end

  subject { instance.perform(args) }

  context 'through delayed_job' do
    before do
      config_worker_as :delayed_job
    end

    context 'with :check_queue' do
      it { is_expected.to be_truthy }
    end

    context 'with :fire_migration' do
      let(:called_worker) { :fire_migration }
      let(:args) { [async_schema_migration.id] }

      it { expect { subject }.to raise_error(RailsAsyncMigrations::Error) }
    end
  end

  context 'through sidekiq' do
    before do
      config_worker_as :sidekiq
    end

    context 'with :check_queue' do
      it { is_expected.to be_truthy }

      context "with custom queue specified" do
        before do
          RailsAsyncMigrations.config do |config|
            config.sidekiq_queue = :another
          end
        end
        it 'sets queue' do
          subject
          expect(RailsAsyncMigrations::Workers::Sidekiq::CheckQueueWorker.jobs.first["queue"]).to eq "another"
        end
      end
    end

    context 'with :fire_migration' do
      let(:called_worker) { :fire_migration }
      let(:args) { [async_schema_migration.id] }

      it { is_expected.to be_truthy }

      context 'with custom queue specified' do
        before do
          RailsAsyncMigrations.config do |config|
            config.sidekiq_queue = :another
          end
        end
        it 'sets queue' do
          subject
          expect(RailsAsyncMigrations::Workers::Sidekiq::FireMigrationWorker.jobs.first["queue"]).to eq "another"
        end
      end

      context 'with custom delay specified' do
        before do
          RailsAsyncMigrations.config do |config|
            config.delay = 2.minutes
          end
        end

        it 'sets the delay' do
          subject
          expect(RailsAsyncMigrations::Workers::Sidekiq::FireMigrationWorker).to have_enqueued_sidekiq_job(1).in(2.minutes)
        end
      end

      context 'with custom retry count specified' do
        before do
          RailsAsyncMigrations.config do |config|
            config.retry = 2
          end
        end

        it 'sets the retry' do
          subject
          expect(RailsAsyncMigrations::Workers::Sidekiq::FireMigrationWorker.jobs.first["retry"]).to eq 2
        end
      end
    end
  end
end
