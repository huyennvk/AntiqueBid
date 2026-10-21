/**
 * CORE.JS - JavaScript hệ thống cốt lõi cho sàn đấu giá Cổ Vật Đường
 * Chức năng:
 *  1. Đồng hồ hệ thống máy chủ (Live Master Clock) chạy thời gian thực trên Header
 *  2. Bộ đếm ngược thời gian đấu giá (Realtime Countdown Timers) tự động cập nhật từng giây
 *  3. Đồng bộ mốc thời gian máy chủ (Server Time Sync) chống lệch đồng hồ máy khách
 */

(function () {
    'use strict';

    // 1. Tính toán thời gian máy chủ chuẩn (Server Time)
    function getServerNow() {
        if (typeof window.__SERVER_TIME__ === 'number' && typeof window.__CLIENT_LOAD_TIME__ === 'number') {
            var elapsed = Date.now() - window.__CLIENT_LOAD_TIME__;
            return new Date(window.__SERVER_TIME__ + elapsed);
        }
        return new Date();
    }

    function padZero(num) {
        return num < 10 ? '0' + num : '' + num;
    }

    // 2. Cập nhật Đồng hồ hệ thống trên Header (Giờ + Thứ, Ngày Tháng Năm)
    function updateSystemClock(serverNow) {
        var clockElement = document.getElementById('system-live-clock');
        var dateElement = document.getElementById('system-live-date');
        if (!clockElement) return;

        var h = padZero(serverNow.getHours());
        var m = padZero(serverNow.getMinutes());
        var s = padZero(serverNow.getSeconds());

        clockElement.textContent = h + ':' + m + ':' + s;

        var d = padZero(serverNow.getDate());
        var mo = padZero(serverNow.getMonth() + 1);
        var y = serverNow.getFullYear();

        if (dateElement) {
            var dayNames = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
            var dayStr = dayNames[serverNow.getDay()];
            dateElement.textContent = dayStr + ', ' + d + '/' + mo + '/' + y;
        }

        // Cập nhật tooltip hiển thị ngày giờ chuẩn đầy đủ
        var widget = document.getElementById('system-clock-widget');
        if (widget) {
            widget.setAttribute('title', 'Giờ chuẩn sàn AntiqueBid: ' + d + '/' + mo + '/' + y + ' ' + h + ':' + m + ':' + s + ' (UTC+7)');
        }
    }

    // 3. Cập nhật tất cả các đồng hồ đếm ngược phiên đấu giá trên toàn bộ trang
    function updateAllCountdowns(serverNow) {
        var nowMillis = serverNow.getTime();
        var countdownElements = document.querySelectorAll('[data-countdown-end]');
        if (!countdownElements || countdownElements.length === 0) return;

        countdownElements.forEach(function (el) {
            var endTimestamp = parseInt(el.getAttribute('data-countdown-end'), 10);
            if (!endTimestamp || isNaN(endTimestamp)) return;

            var diffSeconds = Math.floor((endTimestamp - nowMillis) / 1000);

            if (diffSeconds <= 0) {
                el.textContent = 'Đã kết thúc';
                el.classList.add('countdown-ended');
                el.classList.remove('countdown-urgent');

                // Nếu là thẻ đấu giá trong danh mục, cập nhật nút và badge
                var card = el.closest('.auction-card');
                if (card && !card.classList.contains('auction-card-closed')) {
                    card.classList.add('auction-card-closed');
                    var badge = card.querySelector('.auction-card-badge');
                    if (badge) {
                        badge.className = 'badge badge-closed auction-card-badge';
                        badge.innerHTML = 'ĐÃ KẾT THÚC';
                    }
                    var btn = card.querySelector('.btn-gold.btn-block');
                    if (btn) {
                        btn.className = 'btn btn-dark btn-block';
                        btn.textContent = 'Đã Kết Thúc';
                    }
                }
                return;
            }

            var days = Math.floor(diffSeconds / 86400);
            var remSeconds = diffSeconds % 86400;
            var hours = Math.floor(remSeconds / 3600);
            remSeconds %= 3600;
            var minutes = Math.floor(remSeconds / 60);
            var seconds = remSeconds % 60;

            var timeFormatted = padZero(hours) + ':' + padZero(minutes) + ':' + padZero(seconds);
            if (days > 0) {
                timeFormatted = days + ' ngày ' + timeFormatted;
            }

            el.textContent = timeFormatted;

            // Nhấp nháy cảnh báo nếu còn dưới 5 phút (300s)
            if (diffSeconds <= 300) {
                el.classList.add('countdown-urgent');
            } else {
                el.classList.remove('countdown-urgent');
            }
        });
    }

    // 4. Nhịp đập hệ thống mỗi giây (Heartbeat loop)
    function tick() {
        var serverNow = getServerNow();
        updateSystemClock(serverNow);
        updateAllCountdowns(serverNow);
    }

    // 5. Xử lý Dropdown Tài Khoản Người Dùng (User Profile Dropdown)
    window.toggleUserDropdown = function (e) {
        if (e) {
            e.preventDefault();
            e.stopPropagation();
        }
        var dropdown = document.getElementById('userMenuDropdown');
        if (dropdown) {
            dropdown.classList.toggle('open');
            var trigger = document.getElementById('userMenuTrigger');
            if (trigger) {
                var isOpen = dropdown.classList.contains('open');
                trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            }
        }
    };

    // 6. Xử lý Nút Tìm Kiếm Nhanh Dạng Tròn (Quick Search Popover)
    window.toggleNavSearch = function (e) {
        if (e) {
            e.preventDefault();
            e.stopPropagation();
        }
        var popover = document.getElementById('navSearchPopover');
        if (popover) {
            popover.classList.toggle('open');
            if (popover.classList.contains('open')) {
                var input = document.getElementById('navSearchKeywordInput');
                if (input) {
                    setTimeout(function () { input.focus(); }, 60);
                }
            }
        }
    };

    document.addEventListener('click', function (e) {
        var dropdown = document.getElementById('userMenuDropdown');
        if (dropdown && !dropdown.contains(e.target)) {
            dropdown.classList.remove('open');
            var trigger = document.getElementById('userMenuTrigger');
            if (trigger) trigger.setAttribute('aria-expanded', 'false');
        }

        var searchWrapper = document.getElementById('navSearchDropdown');
        var searchPopover = document.getElementById('navSearchPopover');
        if (searchPopover && searchWrapper && !searchWrapper.contains(e.target)) {
            searchPopover.classList.remove('open');
        }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            var dropdown = document.getElementById('userMenuDropdown');
            if (dropdown && dropdown.classList.contains('open')) {
                dropdown.classList.remove('open');
                var trigger = document.getElementById('userMenuTrigger');
                if (trigger) {
                    trigger.setAttribute('aria-expanded', 'false');
                    trigger.focus();
                }
            }

            var searchPopover = document.getElementById('navSearchPopover');
            if (searchPopover && searchPopover.classList.contains('open')) {
                searchPopover.classList.remove('open');
            }
        }
    });

    // 6. Khởi chạy nhịp đập hệ thống ngay lập tức
    tick();
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () {
            tick();
            setInterval(tick, 1000);
        });
    } else {
        setInterval(tick, 1000);
    }
})();
