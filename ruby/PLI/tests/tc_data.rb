require 'test/unit'
require_relative '../data'

class TestData < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @obj = PLI::Data.new
  end

  def test_mono_dimensional_param
    name = 'test_set'
    set = %w(carbonara risotto_alle)
    expected_hash = {'carbonara' => 1, 'risotto_alle'=>0}
    real_empty_hash = {'carbonara'=>0, 'risotto_alle'=>0}

    #Assicura la linearizzazione in caso di hash vuoto
    assert_equal(real_empty_hash, @obj.mono_dimensional_param(set, {}, name))
    #Assicura che le chiavi vengano compattate
    assert_equal(expected_hash, @obj.mono_dimensional_param(set, {'risotto alle'=>0, 'carbonara'=>1}, name))
    #Assicura la trasformazione in stinghe delle chiavi
    assert_equal(expected_hash, @obj.mono_dimensional_param(set, {risotto_alle: 0, carbonara: 1}, name))
  end
  def test_mono_dimensional_param_rescue
    #Assicura il non inserimento di parametri inconsistenti (non presenti nei set)
    assert_raise(PLI::Exceptions::Inconsistency){@obj.mono_dimensional_param ['set1'], {set2: 1}, 'test_set'}
    #Assicura il non inserimento di parametri non numerici
    assert_raise(TypeError){@obj.mono_dimensional_param ['set1'], {set1: 'a'}, 'test_set'}
  end
  def test_bi_dimensional_param_correct
    row_set = %w(carbonara)
    col_set = %w(uova pancetta)
    row_name = 'rows'
    col_name = 'cols'
    param = {
        carbonara: {
            uova: 1,
            pancetta: 1
        }
    }
    #Assicura il corretto inserimento dei dati
    assert_equal({'carbonara'=>{'uova'=>1, 'pancetta'=>1}}, @obj.bi_dimensional_param(row_set, col_set, param, row_name, col_name))
    #Assicura la linearizzazione in caso di componenti vuoti quando il parametro  facoltativo
    assert_equal({'carbonara'=>{'uova'=>0, 'pancetta'=>0}}, @obj.bi_dimensional_param(row_set, col_set, {}, row_name, col_name, false))
  end
  def test_bi_dimensional_param_rescue
    row_set = %w(carbonara)
    col_set = %w(uova pancetta)
    row_name = 'rows'
    col_name = 'cols'
    not_exs_row = {
        carbonarra: {
            uova: 1,
            pancetta: 1
        }
    }
    not_exs_col = {
        carbonara: {
            uovva: 1,
            pancetta: 1
        }
    }
    type_err = {
        carbonara: {
            uova: 'f',
            pancetta: 1
        }
    }
    #Assicura che non vengano inseriti parametri inconsistenti sulle righe
    assert_raise( PLI::Exceptions::Inconsistency ){@obj.bi_dimensional_param(row_set, col_set, not_exs_row, row_name, col_name)}
    #Assicura che non vengano inseriti parametri inconsistenti sulle colonne
    assert_raise( PLI::Exceptions::Inconsistency ){@obj.bi_dimensional_param(row_set, col_set, not_exs_col, row_name, col_name)}
    #Assicura che non vi siano righe mancanti in caso di obbligatorieta
    assert_raise( PLI::Exceptions::Inconsistency ){@obj.bi_dimensional_param(row_set, col_set, {}, row_name, col_name)}
    #Assicura che non vengano inseriti parametri non numerici
    assert_raise( TypeError ){@obj.bi_dimensional_param(row_set, col_set, type_err, row_name, col_name)}

  end
  def test_sanitize_string
    assert_equal('che_brao_scet', @obj.sanitize_string('Che BRAO sCeT          '))
  end
end