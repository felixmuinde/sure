# frozen_string_literal: true

Rails.application.config.x.play_store.package_name = ENV.fetch("PLAY_STORE_PACKAGE_NAME", "am.sure.mobile")
