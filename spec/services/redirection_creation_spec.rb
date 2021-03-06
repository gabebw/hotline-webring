require "rails_helper"

RSpec.describe RedirectionCreation do
  context "when the referrer is present" do
    it "creates a redirection with the full referrer" do
      referrer_hostname = "https://cool.example.com"
      full_referrer = "#{referrer_hostname}/something/else"
      slug = "cool-slug"

      RedirectionCreation.perform(full_referrer, slug)

      redirection = Redirection.find_by!(slug: slug)
      expect(redirection.url).to eq full_referrer
    end

    it "stores the original unchanged referrer" do
      referrer_hostname = "https://cool.example.com"
      full_referrer = "#{referrer_hostname}/something/else"
      slug = "cool-slug"

      RedirectionCreation.perform(full_referrer, slug)

      redirection = Redirection.find_by!(slug: slug)
      expect(redirection.original_url).to eq full_referrer
    end

    it "links the new redirection into the ring" do
      first_redirection = Redirection.first
      old_next = first_redirection.next

      redirection = RedirectionCreation.perform(
        "http://example.com",
        "slug"
      )

      expect(redirection.previous).to eq first_redirection
      expect(redirection.next).to eq old_next
    end
  end

  context "when the referrer is blank" do
    it "always returns nil" do
      result = RedirectionCreation.perform("", "slug")

      expect(result).to be_nil
    end
  end
end
