module RedmineGitHosting
  class GitAccess

    DOWNLOAD_COMMANDS = %w{ git-upload-pack git-upload-archive }
    PUSH_COMMANDS = %w{ git-receive-pack }


    def download_access_check(actor, repository, is_ssl = false)
      # First check that SmartHTTP is enabled for repository
      return smart_http_is_disabled!(repository) if !smart_http_enabled_for_download?(repository, is_ssl)

      # Then check user permissions
      if actor.is_a?(User)
        user_download_access_check(actor, repository)
      else
        raise 'Wrong actor'
      end
    end


    def upload_access_check(actor, repository)
      # First check that SmartHTTP is enabled for repository
      return smart_http_is_disabled!(repository) if !smart_http_enabled_for_upload?(repository)

      # Then check user permissions
      if actor.is_a?(User)
        user_upload_access_check(actor, repository)
      else
        raise 'Wrong actor'
      end
    end


    def user_download_access_check(user, repository)
      if user && user.allowed_to?(:view_changesets, repository.project)
        build_status_object(true)
      else
        build_status_object(false, "You don't have access")
      end
    end


    def user_upload_access_check(user, repository)
      if user && user.allowed_to?(:commit_access, repository.project)
        build_status_object(true)
      else
        build_status_object(false, "You don't have access")
      end
    end


    protected


      def build_status_object(status, message = '')
        logger.warn(message) if !status
        GitAccessStatus.new(status, message)
      end


    private


      def smart_http_is_disabled!(repository)
        build_status_object(false, "SmartHTTP is disabled for repository '#{repository.gitolite_repository_name}' !")
      end


      def smart_http_enabled_for_download?(repository, is_ssl = false)
        # SmartHTTP is disabled
        return false if repository.extra[:git_http] == 0
        # HTTPS only but no SSL
        return false if repository.extra[:git_http] == 1 && !is_ssl
        # HTTP only but have SSL (weird..)
        return false if repository.extra[:git_http] == 3 && is_ssl
        # Else return true
        return true
      end


      def smart_http_enabled_for_upload?(repository)
        # HTTPS only
        return true if repository.extra[:git_http] == 1
        # HTTPS and HTTP
        return true if repository.extra[:git_http] == 2
        # Else
        return false
      end


      def logger
        RedmineGitHosting.logger
      end

  end
end