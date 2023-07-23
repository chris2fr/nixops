linksHome = document.createElement("div");
linkGV = document.createElement("a");
linkGV.innerText="G.V.";
linkGV.href="https://www.lesgrandsvoisins.com";
linksHome.appendChild(linkGV);
sep = document.createElement("span");
sep.innerText = " / "
linksHome.appendChild(sep);
linkLesGV = document.createElement("a");
linkLesGV.innerText="moi";
linkLesGV.href="https://www.lesgrandsvoisins.com";
linksHome.appendChild(linkLesGV);
document.getElementsByTagName("md-toolbar")[0].appendChild(linksHome);