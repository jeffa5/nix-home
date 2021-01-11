{
  xdg.configFile."wofi/style.css".text = ''
    * {
      color: #ebdbb2;
      font-family: hack;
    }

    window {
      margin: 10px;
      border: 2px solid #928374;
      background-color: #282828;
    }

    #input {
      margin: 5px;
      border: 2px solid #928374;
      border-radius: 0px;
      background-color: #282828;
      font-weight: bold;
    }

    #input:focus {
      outline: none;
      box-shadow: none;
    }

    #inner-box {
      margin: 5px;
      background-color: #282828;
    }

    #scroll {
      margin: 5px;
      border: 2px solid #928374;
    }

    #entry:selected {
      background-color: #98971a;
    }

    #text:selected {
      font-weight: bold;
    }
  '';
}
