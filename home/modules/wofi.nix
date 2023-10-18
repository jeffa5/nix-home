{...}: let
  background = "#fbf1c7";
  border = "#928374";
  foreground = "#3c3836";
in {
  xdg.configFile."wofi/style.css".text = ''
    * {
      color: ${foreground};
      font-family: hack;
    }

    window {
      margin: 10px;
      border: 2px solid ${border};
      background-color: ${background};
    }

    #input {
      margin: 5px;
      border: 2px solid ${border};
      border-radius: 0px;
      background-color: ${background};
      font-weight: bold;
    }

    #input:focus {
      outline: none;
      box-shadow: none;
    }

    #inner-box {
      margin: 5px;
      background-color: ${background};
    }

    #scroll {
      margin: 5px;
      border: 2px solid ${border};
    }

    #entry:selected {
      background-color: #98971a;
    }

    #text:selected {
      font-weight: bold;
    }
  '';
}
