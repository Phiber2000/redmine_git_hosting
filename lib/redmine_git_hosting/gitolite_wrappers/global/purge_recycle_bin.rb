module RedmineGitHosting
  module GitoliteWrappers
    module Global
      class PurgeRecycleBin < GitoliteWrappers::Base

        def call
          RedmineGitHosting::Recycle.delete_expired_files(object_id)
          RedmineGitHosting.logger.info("purge_recycle_bin : done !")
        end

      end
    end
  end
end
