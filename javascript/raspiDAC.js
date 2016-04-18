function getListItems() {
    radioModel.clear();
    //console.log(network.radioList.length);
    //console.log(network.radioList[0]);
    if (mode === 2) { //Radio
        for (var i = 0; i < network.radioList.length; i++)
        {
            radioModel.append( {"name": network.radioList[i] } );
        }
    }
    if (mode === 1) { //UPNP

    }
    if (mode === 3) { //Input
        for (var i = 0; i < 4; i++)
        {
            radioModel.append( {"name": network.inputList[i] });
        }
    }
}

function setListItem(index) {
    //console.log(index);
    if (mode === 2)
        network.radioListSelected(index);
    if (mode === 3)
        network.inputSelected(index);
    stackView.pop();
}

