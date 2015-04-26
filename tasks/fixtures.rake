namespace :fixtures do
  desc "Refresh spec fixtures with fresh data from gares-en-mouvement.com"
  task :refresh do
    require File.expand_path(File.dirname(__FILE__) + "/../spec/spec_helper")

    ONLY = ENV['ONLY'] ? ENV['ONLY'].split(',') : []
    GARES_SAMPLES.each_pair do |url, fixture|
      next if !ONLY.empty? and !ONLY.include?(fixture)
      page = `curl -is #{url}`

      File.open(File.expand_path(File.dirname(__FILE__) + "/../spec/fixtures/#{fixture}"), 'w') do |f|
        f.write(page)
      end

    end
    TRAINS_SAMPLES.each do |train|
      post_fixture = "post-#{train.values.first}"
      get_fixture = "get-#{train.values.first}"
      train_number = train.keys.first
      next if !ONLY.empty? and !ONLY.include?(post_fixture)
      page = `curl -is 'http://www.sncf.com/sncf/train' --data 'numeroTrain=#{train_number}&date=25%2F04%2F2015'`

      File.open(File.expand_path(File.dirname(__FILE__) + "/../spec/fixtures/#{post_fixture}"), 'w') do |f|
        f.write(page)
      end

      cookies = page.force_encoding('ISO-8859-1').encode('UTF-8').split("\n").map do |line|
        if md = line.match(/Set-Cookie: (.*?);/)
            md.captures.first
        end
      end.compact
      page = `curl -is 'http://www.sncf.com/en/horaires-info-trafic/train/resultats' -H 'Cookie: #{cookies.join(";")}'`

      File.open(File.expand_path(File.dirname(__FILE__) + "/../spec/fixtures/#{get_fixture}"), 'w') do |f|
        f.write(page)
      end

      MULTI_TRAINS_SAMPLES.find { |one| one.keys.first == train_number }.values.first.each_with_index do |fixture, idx|
        get_fixture = "get-#{fixture}"
        get_fixture_data = "#{get_fixture}-data"
        page = `curl -is 'http://www.sncf.com/sncf/train/displayDetailTrain?idItineraire=#{idx}' -H 'Cookie: #{cookies.join(";")}'`

        File.open(File.expand_path(File.dirname(__FILE__) + "/../spec/fixtures/#{get_fixture}"), 'w') do |f|
          f.write(page)
        end

        page = `curl -is 'http://www.sncf.com/en/horaires-info-trafic/train/resultats?#{idx}' -H 'Cookie: #{cookies.join(";")}'`

        File.open(File.expand_path(File.dirname(__FILE__) + "/../spec/fixtures/#{get_fixture_data}"), 'w') do |f|
          f.write(page)
        end

      end
    end
  end
end
