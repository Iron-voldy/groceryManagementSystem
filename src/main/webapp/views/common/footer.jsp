</main>

    <footer class="footer mt-5 py-4 bg-light">
        <div class="container">
            <div class="row">
                <div class="col-md-4">
                    <h5>GroceryShop</h5>
                    <p>Quality groceries delivered to your doorstep. Fresh products, competitive prices, and exceptional service.</p>
                </div>
                <div class="col-md-3">
                    <h5>Quick Links</h5>
                    <ul class="list-unstyled">
                        <li><a href="${pageContext.request.contextPath}/">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/list">Products</a></li>
                        <li><a href="${pageContext.request.contextPath}/views/user/register.jsp">Register</a></li>
                        <li><a href="${pageContext.request.contextPath}/views/user/login.jsp">Login</a></li>
                    </ul>
                </div>
                <div class="col-md-3">
                    <h5>Categories</h5>
                    <ul class="list-unstyled">
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Fresh Products">Fresh Products</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Dairy">Dairy</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Vegetables">Vegetables</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Fruits">Fruits</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Pantry Items">Pantry Items</a></li>
                    </ul>
                </div>
                <div class="col-md-2">
                    <h5>Contact Us</h5>
                    <ul class="list-unstyled">
                        <li><i class="fas fa-envelope mr-2"></i> info@groceryshop.com</li>
                        <li><i class="fas fa-phone mr-2"></i> +123-456-7890</li>
                    </ul>
                </div>
            </div>
            <hr>
            <div class="row">
                <div class="col-md-6">
                    <p>&copy; 2025 GroceryShop. All rights reserved.</p>
                </div>
                <div class="col-md-6 text-right">
                    <a href="#" class="mr-3"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="mr-3"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="mr-3"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-pinterest"></i></a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Notification Container -->
    <div id="notification-container"></div>

    <!-- jQuery and Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Global JavaScript -->
    <script>
        // Exactly one declaration of contextPath
        const contextPath = '${pageContext.request.contextPath}';

        // Show notification function
        function showNotification(message, type = 'success') {
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

        // Form validation
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form[data-validate="true"]');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    let isValid = true;

                    // Validate required fields
                    const requiredFields = form.querySelectorAll('[required]');
                    requiredFields.forEach(field => {
                        if (!field.value.trim()) {
                            isValid = false;
                            field.classList.add('is-invalid');
                        } else {
                            field.classList.remove('is-invalid');
                        }
                    });

                    // Validate password
                    const passwordFields = form.querySelectorAll('[data-validate-password="true"]');
                    passwordFields.forEach(field => {
                        if (field.value) {
                            const minLength = field.getAttribute('data-min-length') || 8;
                            const hasUppercase = /[A-Z]/.test(field.value);
                            const hasLowercase = /[a-z]/.test(field.value);
                            const hasNumber = /\d/.test(field.value);

                            if (field.value.length < minLength || !hasUppercase || !hasLowercase || !hasNumber) {
                                isValid = false;
                                field.classList.add('is-invalid');
                                // You can add more detailed feedback here
                            } else {
                                field.classList.remove('is-invalid');
                            }
                        }
                    });

                    // Validate matching fields
                    const matchFields = form.querySelectorAll('[data-match]');
                    matchFields.forEach(field => {
                        const targetSelector = field.getAttribute('data-match');
                        const targetField = document.querySelector(targetSelector);

                        if (targetField && field.value !== targetField.value) {
                            isValid = false;
                            field.classList.add('is-invalid');
                        } else {
                            field.classList.remove('is-invalid');
                        }
                    });

                    if (!isValid) {
                        e.preventDefault();
                        showNotification('Please correct the errors in the form', 'error');
                    }
                });
            });

            // Password toggle functionality
            const passwordToggles = document.querySelectorAll('.password-toggle');
            passwordToggles.forEach(toggle => {
                toggle.addEventListener('click', function() {
                    const input = this.previousElementSibling;
                    const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                    input.setAttribute('type', type);
                    this.textContent = type === 'password' ? 'Show' : 'Hide';
                });
            });
        });
    </script>
</body>
</html>