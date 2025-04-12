</main>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h3 class="footer-title">GroceryShop</h3>
                    <p>Your one-stop solution for fresh groceries and household essentials. Shop with us for quality products and exceptional service.</p>
                </div>

                <div class="footer-section">
                    <h3 class="footer-title">Quick Links</h3>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/list">Products</a></li>
                        <li><a href="${pageContext.request.contextPath}/views/about.jsp">About Us</a></li>
                        <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact Us</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3 class="footer-title">Categories</h3>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Fresh+Products">Fresh Products</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Dairy">Dairy</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Vegetables">Vegetables</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Fruits">Fruits</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/category?category=Pantry+Items">Pantry Items</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3 class="footer-title">Contact Us</h3>
                    <p>Email: support@groceryshop.com</p>
                    <p>Phone: +1 (555) 123-4567</p>
                    <p>Address: 123 Grocery St, Shopping City, SC 12345</p>
                </div>
            </div>

            <div class="copyright">
                &copy; <%= new java.util.Date().getYear() + 1900 %> GroceryShop. All rights reserved.
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <!-- Additional scripts based on page needs -->
    <c:if test="${param.scripts != null}">
        <c:forEach var="script" items="${param.scripts}">
            <script src="${pageContext.request.contextPath}/assets/js/${script}.js"></script>
        </c:forEach>
    </c:if>
</body>
</html>