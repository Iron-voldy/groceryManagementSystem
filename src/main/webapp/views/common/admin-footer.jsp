</main>
    </div>

    <!-- Notification Container -->
    <div id="notification-container"></div>

    <!-- jQuery and Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Global JavaScript for Admin -->
    <script>
        // Define a single instance of contextPath
        const contextPath = '${pageContext.request.contextPath}';

        // Sidebar Toggle
        document.addEventListener('DOMContentLoaded', function() {
            const sidebarToggle = document.getElementById('sidebarToggle');
            const sidebar = document.getElementById('sidebar');

            if (sidebarToggle && sidebar) {
                sidebarToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('sidebar-collapsed');
                });
            }

            // Function to show notification
            window.showNotification = function(message, type = 'success') {
                const notification = document.createElement('div');
                notification.className = `notification ${type}`;
                notification.textContent = message;

                const container = document.getElementById('notification-container');
                container.appendChild(notification);

                // Trigger reflow before adding show class
                notification.offsetWidth;

                // Add show class to start animation
                notification.classList.add('show');

                // Remove notification after delay
                setTimeout(() => {
                    notification.classList.remove('show');
                    setTimeout(() => {
                        notification.remove();
                    }, 300);
                }, 3000);
            }

            // Handle "Select All" checkbox for tables
            const selectAllCheckbox = document.getElementById('select-all');
            if (selectAllCheckbox) {
                selectAllCheckbox.addEventListener('change', function() {
                    const checkboxes = document.querySelectorAll('input[name="selected-items"]');
                    checkboxes.forEach(checkbox => {
                        checkbox.checked = this.checked;
                    });
                });
            }

            // Table sorting functionality
            const sortableHeaders = document.querySelectorAll('th[data-sort]');
            sortableHeaders.forEach(header => {
                header.addEventListener('click', function() {
                    const sortBy = this.getAttribute('data-sort');
                    const currentOrder = this.classList.contains('sort-asc') ? 'desc' : 'asc';

                    // Remove sort classes from all headers
                    sortableHeaders.forEach(h => {
                        h.classList.remove('sort-asc', 'sort-desc');
                    });

                    // Add sort class to current header
                    this.classList.add(`sort-${currentOrder}`);

                    // Get table and item type
                    const table = this.closest('table');
                    const itemType = table.getAttribute('data-item-type');

                    // Call sort function based on item type
                    if (window.sortTable) {
                        window.sortTable(table, sortBy, currentOrder);
                    } else {
                        // Default sorting implementation
                        sortTable(table, sortBy, currentOrder);
                    }
                });

                // Set default sort if specified
                if (header.hasAttribute('data-default-sort')) {
                    const defaultOrder = header.getAttribute('data-default-sort');
                    header.classList.add(`sort-${defaultOrder}`);

                    // Get table and trigger initial sort
                    const table = header.closest('table');
                    const sortBy = header.getAttribute('data-sort');

                    // Delay sorting to ensure DOM is fully loaded
                    setTimeout(() => {
                        if (window.sortTable) {
                            window.sortTable(table, sortBy, defaultOrder);
                        } else {
                            // Default sorting implementation
                            sortTable(table, sortBy, defaultOrder);
                        }
                    }, 100);
                }
            });

            // Default table sorting function
            function sortTable(table, sortBy, order) {
                const tbody = table.querySelector('tbody');
                const rows = Array.from(tbody.querySelectorAll('tr'));

                rows.sort((a, b) => {
                    let aValue, bValue;

                    const aCell = a.querySelector(`td[data-${sortBy}]`);
                    const bCell = b.querySelector(`td[data-${sortBy}]`);

                    if (aCell && bCell) {
                        aValue = aCell.getAttribute(`data-${sortBy}`);
                        bValue = bCell.getAttribute(`data-${sortBy}`);
                    } else {
                        // Get cell index based on header position
                        const headerIndex = Array.from(table.querySelectorAll(`th[data-sort="${sortBy}"]`))[0].cellIndex;
                        aValue = a.cells[headerIndex].textContent.trim();
                        bValue = b.cells[headerIndex].textContent.trim();
                    }

                    // Try to convert to numbers if possible
                    const aNum = parseFloat(aValue);
                    const bNum = parseFloat(bValue);

                    if (!isNaN(aNum) && !isNaN(bNum)) {
                        return order === 'asc' ? aNum - bNum : bNum - aNum;
                    }

                    // Otherwise compare as strings
                    return order === 'asc'
                        ? aValue.localeCompare(bValue)
                        : bValue.localeCompare(aValue);
                });

                // Re-append rows in new order
                rows.forEach(row => tbody.appendChild(row));
            }
        });
    </script>
</body>
</html>