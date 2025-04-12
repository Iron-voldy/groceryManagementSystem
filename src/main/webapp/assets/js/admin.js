// admin.js - Admin dashboard functionality

document.addEventListener('DOMContentLoaded', function() {
    initAdminFunctionality();
    initDataTables();
    initCharts();
});

function initAdminFunctionality() {
    // Mobile sidebar toggle
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('show');
        });
    }

    // Confirmation for delete actions
    const deleteButtons = document.querySelectorAll('.delete-btn, [data-action="delete"]');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            if (!confirm('Are you sure you want to delete this item? This action cannot be undone.')) {
                e.preventDefault();
            }
        });
    });

    // Status change handling
    const statusSelects = document.querySelectorAll('.status-select');
    statusSelects.forEach(select => {
        select.addEventListener('change', function() {
            const itemId = this.getAttribute('data-id');
            const itemType = this.getAttribute('data-type');
            const newStatus = this.value;

            updateItemStatus(itemId, itemType, newStatus);
        });
    });

    // Bulk actions
    const bulkActionSelect = document.getElementById('bulk-action');
    const applyBulkActionBtn = document.getElementById('apply-bulk-action');

    if (bulkActionSelect && applyBulkActionBtn) {
        applyBulkActionBtn.addEventListener('click', function() {
            const selectedItems = document.querySelectorAll('input[name="selected-items"]:checked');
            if (selectedItems.length === 0) {
                alert('Please select at least one item');
                return;
            }

            const action = bulkActionSelect.value;
            if (!action) {
                alert('Please select an action');
                return;
            }

            const itemIds = Array.from(selectedItems).map(item => item.value);
            const itemType = document.querySelector('table').getAttribute('data-item-type');

            if (action === 'delete' && !confirm(`Are you sure you want to delete ${selectedItems.length} selected items? This action cannot be undone.`)) {
                return;
            }

            processBulkAction(itemIds, itemType, action);
        });
    }

    // Select all checkbox
    const selectAllCheckbox = document.getElementById('select-all');
    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('input[name="selected-items"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });
    }

    // Filter and search functionality
    const filterForm = document.getElementById('filter-form');
    if (filterForm) {
        filterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            applyFilters();
        });

        const filterInputs = filterForm.querySelectorAll('select, input:not([type="submit"])');
        filterInputs.forEach(input => {
            input.addEventListener('change', function() {
                if (this.getAttribute('data-instant-filter') === 'true') {
                    applyFilters();
                }
            });
        });
    }

    // Date range pickers
    const dateRangePickers = document.querySelectorAll('.date-range-picker');
    if (dateRangePickers.length > 0) {
        dateRangePickers.forEach(picker => {
            const startDate = picker.querySelector('.start-date');
            const endDate = picker.querySelector('.end-date');

            if (startDate && endDate) {
                startDate.addEventListener('change', function() {
                    endDate.min = this.value;
                    if (endDate.value && new Date(endDate.value) < new Date(this.value)) {
                        endDate.value = this.value;
                    }
                });

                endDate.addEventListener('change', function() {
                    startDate.max = this.value;
                });
            }
        });
    }
}

function initDataTables() {
    const tables = document.querySelectorAll('.data-table');
    tables.forEach(table => {
        const searchInput = document.querySelector(`#${table.id}-search`);
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const searchText = this.value.toLowerCase();
                const rows = table.querySelectorAll('tbody tr');

                rows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    row.style.display = text.includes(searchText) ? '' : 'none';
                });

                updateTableStats(table);
            });
        }

        // Sorting
        const headers = table.querySelectorAll('th[data-sort]');
        headers.forEach(header => {
            header.addEventListener('click', function() {
                const sortKey = this.getAttribute('data-sort');
                const currentDirection = this.getAttribute('data-direction') || 'asc';
                const newDirection = currentDirection === 'asc' ? 'desc' : 'asc';

                // Remove sort direction from all headers
                headers.forEach(h => {
                    h.removeAttribute('data-direction');
                    h.classList.remove('sort-asc', 'sort-desc');
                });

                // Set sort direction on clicked header
                this.setAttribute('data-direction', newDirection);
                this.classList.add(`sort-${newDirection}`);

                sortTable(table, sortKey, newDirection);
            });
        });

        // Initial sort if specified
        const defaultSortHeader = table.querySelector('th[data-default-sort]');
        if (defaultSortHeader) {
            defaultSortHeader.click();
        }
    });
}

function sortTable(table, sortKey, direction) {
    const rows = Array.from(table.querySelectorAll('tbody tr'));
    const tbody = table.querySelector('tbody');
    const multiplier = direction === 'asc' ? 1 : -1;

    rows.sort((a, b) => {
        let valueA = a.querySelector(`td[data-${sortKey}]`).getAttribute(`data-${sortKey}`);
        let valueB = b.querySelector(`td[data-${sortKey}]`).getAttribute(`data-${sortKey}`);

        // If values don't exist in data attribute, get from cell content
        if (!valueA) valueA = a.querySelector(`td:nth-child(${getColumnIndex(table, sortKey) + 1})`).textContent.trim();
        if (!valueB) valueB = b.querySelector(`td:nth-child(${getColumnIndex(table, sortKey) + 1})`).textContent.trim();

        // Determine data type and compare
        if (isNaN(valueA)) {
            return valueA.localeCompare(valueB) * multiplier;
        } else {
            return (parseFloat(valueA) - parseFloat(valueB)) * multiplier;
        }
    });

    // Update table with sorted rows
    tbody.innerHTML = '';
    rows.forEach(row => tbody.appendChild(row));

    updateTableStats(table);
}

function getColumnIndex(table, key) {
    const headers = table.querySelectorAll('th');
    let columnIndex = 0;

    for (let i = 0; i < headers.length; i++) {
        if (headers[i].getAttribute('data-sort') === key) {
            columnIndex = i;
            break;
        }
    }

    return columnIndex;
}

function updateTableStats(table) {
    const visibleRows = table.querySelectorAll('tbody tr:not([style*="display: none"])');
    const totalRows = table.querySelectorAll('tbody tr').length;
    const statsElement = document.querySelector(`#${table.id}-stats`);

    if (statsElement) {
        statsElement.textContent = `Showing ${visibleRows.length} of ${totalRows} items`;
    }
}

function updateItemStatus(itemId, itemType, newStatus) {
    fetch(`${contextPath}/${itemType}/update-status`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: `id=${itemId}&status=${newStatus}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(`${itemType.charAt(0).toUpperCase() + itemType.slice(1)} status updated successfully`);

            // Update status classes on the row
            const row = document.querySelector(`tr[data-id="${itemId}"]`);
            if (row) {
                // Remove all status classes
                row.classList.remove('status-pending', 'status-processing', 'status-shipped', 'status-delivered', 'status-cancelled');
                // Add new status class
                row.classList.add(`status-${newStatus.toLowerCase()}`);
            }
        } else {
            showNotification(data.message || 'Failed to update status', 'error');
        }
    })
    .catch(error => {
        console.error('Error updating status:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function processBulkAction(itemIds, itemType, action) {
    fetch(`${contextPath}/${itemType}/bulk-action`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            ids: itemIds,
            action: action
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(`${data.processedCount} items processed successfully`);

            // Refresh the page or update UI
            if (action === 'delete') {
                itemIds.forEach(id => {
                    const row = document.querySelector(`tr[data-id="${id}"]`);
                    if (row) row.remove();
                });

                updateTableStats(document.querySelector('table'));
            } else {
                window.location.reload();
            }
        } else {
            showNotification(data.message || 'Failed to process bulk action', 'error');
        }
    })
    .catch(error => {
        console.error('Error processing bulk action:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

function applyFilters() {
    const form = document.getElementById('filter-form');
    const formData = new FormData(form);

    // Convert FormData to query string
    const queryString = new URLSearchParams(formData).toString();

    // Redirect with filters
    window.location.href = `${window.location.pathname}?${queryString}`;
}

function initCharts() {
    // Sales chart
    const salesChartElement = document.getElementById('sales-chart');
    if (salesChartElement) {
        const ctx = salesChartElement.getContext('2d');

        // Get chart data from data attribute or fetch from API
        let chartData;
        try {
            chartData = JSON.parse(salesChartElement.getAttribute('data-chart'));
        } catch (error) {
            console.error('Error parsing chart data:', error);
            chartData = {
                labels: [],
                datasets: []
            };
        }

        new Chart(ctx, {
            type: 'line',
            data: chartData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#b0b0b0'
                        }
                    },
                    x: {
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#b0b0b0'
                        }
                    }
                },
                plugins: {
                    legend: {
                        labels: {
                            color: '#e0e0e0'
                        }
                    }
                }
            }
        });
    }

    // Product categories chart
    const categoriesChartElement = document.getElementById('categories-chart');
    if (categoriesChartElement) {
        const ctx = categoriesChartElement.getContext('2d');

        // Get chart data from data attribute or fetch from API
        let chartData;
        try {
            chartData = JSON.parse(categoriesChartElement.getAttribute('data-chart'));
        } catch (error) {
            console.error('Error parsing chart data:', error);
            chartData = {
                labels: [],
                datasets: []
            };
        }

        new Chart(ctx, {
            type: 'doughnut',
            data: chartData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: '#e0e0e0'
                        }
                    }
                }
            }
        });
    }
}

function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 10);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}