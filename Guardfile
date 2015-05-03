group 'gem' do
  guard 'rspec', :cmd => "bundle exec rspec", :all_on_start => false, :all_after_pass => false, :failed_mode => :focus do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/gares/(.+)\.rb$})                          { |m| "spec/gares/#{m[1]}_spec.rb" }
  end
end
