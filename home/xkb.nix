{
  xdg.configFile."xkb/symbols/iso-uk-colemak-dh".text = ''
    partial alphanumeric_keys
    default xkb_symbols "colemak-dh" {
      include "gb"
      name[Group1] = "UK (Colemak DH)";

      key <AD03> { [ f, F ] };
      key <AD04> { [ p, P ] };
      key <AD05> { [ b, B ] };
      key <AD06> { [ j, J ] };
      key <AD07> { [ l, L ] };
      key <AD08> { [ u, U ] };
      key <AD09> { [ y, Y ] };
      key <AD10> { [ semicolon, colon ] };

      key <AC02> { [ r, R ] };
      key <AC03> { [ s, S ] };
      key <AC04> { [ t, T ] };
      key <AC06> { [ m, M ] };
      key <AC07> { [ n, N ] };
      key <AC08> { [ e, E ] };
      key <AC09> { [ i, I ] };
      key <AC10> { [ o, O ] };

      key <AB04> { [ d, D ] };
      key <AB05> { [ v, V ] };
      key <AB06> { [ k, K ] };
      key <AB07> { [ h, H ] };
    };
  '';

  xdg.configFile."xkb/symbols/iso-us-colemak-dh".text = ''
    partial alphanumeric_keys
    default xkb_symbols "colemak-dh" {
      include "us"
      name[Group1] = "US (Colemak DH)";

      key <AD03> { [ f, F ] };
      key <AD04> { [ p, P ] };
      key <AD05> { [ b, B ] };
      key <AD06> { [ j, J ] };
      key <AD07> { [ l, L ] };
      key <AD08> { [ u, U ] };
      key <AD09> { [ y, Y ] };
      key <AD10> { [ semicolon, colon ] };

      key <AC02> { [ r, R ] };
      key <AC03> { [ s, S ] };
      key <AC04> { [ t, T ] };
      key <AC06> { [ m, M ] };
      key <AC07> { [ n, N ] };
      key <AC08> { [ e, E ] };
      key <AC09> { [ i, I ] };
      key <AC10> { [ o, O ] };

      key <AB04> { [ d, D ] };
      key <AB05> { [ v, V ] };
      key <AB06> { [ k, K ] };
      key <AB07> { [ h, H ] };
    };
  '';
}
