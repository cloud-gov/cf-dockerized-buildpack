@Grab("thymeleaf-spring4")

import org.springframework.core.env.*

@Controller
class Application {

	@RequestMapping("/")
	public String index(Model model) {
		return "index"
	}

}
