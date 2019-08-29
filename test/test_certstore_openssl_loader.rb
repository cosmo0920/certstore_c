require "helper"

class CertstoreOpenSSLLoaderTest < ::Test::Unit::TestCase
  def create_loader(cert_logical_store_name)
    cert_store = OpenSSL::X509::Store.new

    Certstore::OpenSSL::Loader.new(cert_store, cert_logical_store_name)
  end

  def test_load_cert_store
    assert_nothing_raised do
      loader = create_loader("Trust")
      loader.load_cert_store
    end
  end

  def test_load_cert_store_with_noexistent_logical_store_name
    assert_raise(Certstore::Loader::InvalidStoreNameError) do
      loader = create_loader("Noexistent")
      loader.load_cert_store
    end
  end

  def test_get_certificate
    store_name = "ROOT"
    loader = create_loader(store_name)
    store_loader = Certstore::Loader.new(store_name)
    certificate_thumbprints = []
    store_loader.each do |pem|
      x509_certificate_obj = OpenSSL::X509::Certificate.new(pem)
      certificate_thumbprints << OpenSSL::Digest::SHA1.new(x509_certificate_obj.to_der).to_s
    end

    thumbprint = certificate_thumbprints.first
    openssl_x509_obj = loader.get_certificate(thumbprint)
    assert_true openssl_x509_obj.is_a?(OpenSSL::X509::Certificate)
    assert_true loader.valid_duration?(openssl_x509_obj)
  end

  def test_get_certificate_with_nonexistent_thumbprint
    assert_raise(Certstore::Loader::LoaderError) do
      loader = create_loader("ROOT")
      assert_nil loader.get_certificate("nonexistent")
    end
  end
end