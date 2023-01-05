window.onload = () => {
  const yourPlace = document.getElementById("your-place");
  const inputPlace = document.getElementById("input-place");
  const placeCandidate = document.getElementById("place-candidate");

  const successÇallback = (coords) => {
    let message;
    if (coords.latitude === undefined || coords.longitude === undefined) {
      message = "位置情報の取得に失敗しました。";
    }
    else {
      message = `あなたは現在 <strong>緯度 ${coords.latitude}、経度 ${coords.latitude}</strong> にいます。`;
    }
    yourPlace.innerHTML = message;
  };

  const errorCallback = () => {
    alert("位置情報の取得に失敗しました。ブラウザの設定から位置情報の取得を有効にしてください。");
  };

  navigator.geolocation.getCurrentPosition(successÇallback, errorCallback);

  inputPlace.addEventListener("keydown", (e) => {
    if (e.isComposing) {
      return;
    }
    placeCandidate.innerHTML = "";
    const candidates = places.filter(place => place.indexOf(e.target.value) == 0);
    for (const candidate of candidates) {
      const option = document.createElement("option");
      option.value = candidate;
      placeCandidate.appendChild(option);
    }
  });
};
