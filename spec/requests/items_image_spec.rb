require "rails_helper"

RSpec.describe "Items image attachment", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  def uploaded_file(filename)
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/#{filename}").to_s,
      "image/jpeg"
    )
  end

  describe "POST /items" do
    it "createで画像添付でき、judgementとreminderも作成される" do
      expect do
        post items_path, params: {
          item: {
            name: "画像付き商品",
            price: 12_000,
            item_image: uploaded_file("sample.jpg"),
            remind_interval: 3600
          }
        }
      end.to change(Item, :count).by(1)
        .and change(Judgement, :count).by(1)
        .and change(Reminder, :count).by(1)

      created_item = Item.order(:id).last
      expect(created_item.item_image).to be_attached
      expect(created_item.judgement).to be_present
      expect(created_item.reminder).to be_present
    end

    it "item_imageなしで作成したitemは画像未添付になる" do
      expect do
        post items_path, params: {
          item: {
            name: "画像なし商品",
            price: 8_000
          }
        }
      end.to change(Item, :count).by(1)

      created_item = Item.order(:id).last
      expect(created_item.item_image).not_to be_attached
    end
  end

  describe "PATCH /items/:id" do
    let(:item) { create(:item, user: user) }
    let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.from_now, remind_interval: 3600) }
    it "updateで画像添付できる" do
      patch item_path(item), params: {
        item: {
          item_image: uploaded_file("sample.jpg"),
          remind_interval: 3600
        }
      }

      expect(response).to have_http_status(:found)
      expect(item.reload.item_image).to be_attached
    end

    it "既存画像を別画像で差し替えるとblob_idが変わる" do
      item.item_image.attach(uploaded_file("sample.jpg"))
      original_blob_id = item.item_image.blob_id

      patch item_path(item), params: {
        item: {
          item_image: uploaded_file("sample2.jpg"),
          remind_interval: 3600
        }
      }

      item.reload
      expect(item.item_image).to be_attached
      expect(item.item_image.blob_id).not_to eq(original_blob_id)
    end
  end
end
