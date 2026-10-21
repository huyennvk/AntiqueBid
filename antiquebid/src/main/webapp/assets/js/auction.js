document.addEventListener("DOMContentLoaded", function () {
    const auctionRoom = document.getElementById("auction-room-container");
    if (!auctionRoom) return;

    const auctionId = auctionRoom.getAttribute("data-auction-id");
    let remainingSeconds = parseInt(auctionRoom.getAttribute("data-remaining-seconds"), 10) || 0;
    const minIncrement = parseInt(auctionRoom.getAttribute("data-min-increment"), 10) || 1000000;

    const timerElement = document.getElementById("countdown-display");
    const currentPriceElement = document.getElementById("current-price-display");
    const leaderNameElement = document.getElementById("highest-bidder-display");
    const nextMinPriceElement = document.getElementById("next-min-price-display");
    const customBidInput = document.getElementById("custom-bid-input");
    const bidTableBody = document.getElementById("bid-history-tbody");
    const bidToast = document.getElementById("bid-toast");

    // 1. Countdown timer
    function updateCountdown() {
        if (remainingSeconds <= 0) {
            if (timerElement) timerElement.innerText = "00:00:00 (Đã kết thúc)";
            return;
        }
        remainingSeconds--;

        const days = Math.floor(remainingSeconds / (24 * 3600));
        let rem = remainingSeconds % (24 * 3600);
        const hours = Math.floor(rem / 3600);
        rem %= 3600;
        const minutes = Math.floor(rem / 60);
        const seconds = rem % 60;

        const pad = (n) => String(n).padStart(2, '0');
        let text = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
        if (days > 0) text = `${days} ngày ` + text;

        if (timerElement) timerElement.innerText = text;
    }
    setInterval(updateCountdown, 1000);
    updateCountdown();

    // 2. Quick bid increment buttons
    document.querySelectorAll(".quick-bid-btn").forEach(btn => {
        btn.addEventListener("click", function () {
            const multiplier = parseInt(this.getAttribute("data-multiplier"), 10) || 1;
            const currentRaw = parseInt(customBidInput.getAttribute("data-min-value"), 10) || 0;
            const newAmount = currentRaw + (multiplier - 1) * minIncrement;
            customBidInput.value = newAmount.toLocaleString("vi-VN");
        });
    });

    // 3. Bid submission via AJAX
    const bidForm = document.getElementById("place-bid-form");
    if (bidForm) {
        bidForm.addEventListener("submit", function (e) {
            e.preventDefault();
            const rawValue = customBidInput.value.replace(/\./g, "").replace(/,/g, "").trim();
            if (!rawValue || isNaN(rawValue)) {
                showToast("Vui lòng nhập mức giá hợp lệ.", "error");
                return;
            }

            const formData = new URLSearchParams();
            formData.append("auctionId", auctionId);
            formData.append("amount", rawValue);

            const contextPath = auctionRoom.getAttribute("data-context-path") || "";

            fetch(contextPath + "/auction-bid", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast(data.message, "success");
                    pollStatus(); // Immediately update room state
                } else {
                    showToast(data.message, "error");
                }
            })
            .catch(err => {
                showToast("Lỗi kết nối máy chủ: " + err.message, "error");
            });
        });
    }

    // 4. Status polling every 3 seconds
    function pollStatus() {
        const contextPath = auctionRoom.getAttribute("data-context-path") || "";
        fetch(contextPath + "/auction-status?id=" + auctionId)
            .then(res => res.json())
            .then(data => {
                if (!data.success) return;

                if (currentPriceElement) currentPriceElement.innerText = data.currentHighestBidFormatted;
                if (leaderNameElement) leaderNameElement.innerText = maskName(data.highestBidderName);
                if (nextMinPriceElement) nextMinPriceElement.innerText = data.nextMinimumBidFormatted;
                if (customBidInput && !customBidInput.matches(":focus")) {
                    customBidInput.value = data.nextMinimumBid.toLocaleString("vi-VN");
                    customBidInput.setAttribute("data-min-value", data.nextMinimumBid);
                }

                if (data.remainingSeconds !== undefined) {
                    remainingSeconds = data.remainingSeconds;
                }

                // Update bids table
                if (bidTableBody && data.bids) {
                    bidTableBody.innerHTML = "";
                    data.bids.forEach((b, idx) => {
                        const tr = document.createElement("tr");
                        if (idx === 0) tr.className = "highest-bid-row";
                        const formatPrice = Number(b.bidAmount).toLocaleString("vi-VN") + " ₫";
                        const maskedName = maskName(b.bidderName);

                        tr.innerHTML = `
                            <td>${idx + 1}</td>
                            <td><strong>${maskedName}</strong></td>
                            <td class="price-value text-sm text-danger">${formatPrice}</td>
                            <td class="text-muted text-xs">${b.bidTime || "Vừa xong"}</td>
                            <td><span class="badge badge-success">Hợp lệ</span></td>
                        `;
                        bidTableBody.appendChild(tr);
                    });
                }
            })
            .catch(() => {});
    }

    function maskName(name) {
        if (!name || name === "Chưa có lượt trả giá") return "Chưa có lượt trả giá";
        const trimmed = name.trim();
        if (trimmed.includes("****")) return trimmed;
        const parts = trimmed.split(/\s+/);
        return parts.map(p => {
            if (p.length <= 1) return p + "****";
            if (p.length === 2) return p.charAt(0) + "****";
            return p.charAt(0) + "****" + p.charAt(p.length - 1);
        }).join(" ");
    }

    setInterval(pollStatus, 3000);

    function showToast(msg, type) {
        if (!bidToast) {
            alert(msg);
            return;
        }
        bidToast.innerText = msg;
        bidToast.className = "toast show " + (type === "success" ? "toast-success" : "toast-error");
        setTimeout(() => {
            bidToast.className = "toast";
        }, 4000);
    }
});

// Gallery photo switching
window.selectStageImage = function (wrapperElement, fullSrc, fallbackSrc, angleLabel) {
    const mainImg = document.getElementById("main-stage-img");
    const angleBadge = document.getElementById("stage-angle-title");

    if (mainImg) {
        mainImg.style.opacity = "0.5";
        setTimeout(() => {
            mainImg.src = fullSrc;
            mainImg.onerror = function () {
                this.onerror = null;
                this.src = fallbackSrc;
            };
            mainImg.style.opacity = "1";
        }, 150);
    }

    if (angleBadge && angleLabel) {
        angleBadge.innerText = angleLabel;
    }

    document.querySelectorAll(".stage-thumb").forEach(t => t.classList.remove("active"));
    const imgInside = wrapperElement.querySelector(".stage-thumb") || wrapperElement;
    imgInside.classList.add("active");
};

// Dossier tab switching
window.switchDossierTab = function (tabName) {
    document.querySelectorAll(".dossier-tab-btn").forEach(btn => btn.classList.remove("active"));
    document.querySelectorAll(".dossier-tab-pane").forEach(pane => pane.classList.remove("active"));

    const targetBtn = document.getElementById("tab-btn-" + tabName);
    const targetPane = document.getElementById("tab-pane-" + tabName);

    if (targetBtn) targetBtn.classList.add("active");
    if (targetPane) targetPane.classList.add("active");
};

